module Stomp

  # Typical Stomp client class. Uses a listener thread to receive frames
  # from the server, any thread can send.
  #
  # Receives all happen in one thread, so consider not doing much processing
  # in that thread if you have much message volume.
  class Client

    # Accepts a username (default ""), password (default ""),
    # host (default localhost), and port (default 61613)
    def initialize(user = "", pass = "", host = "localhost", port = 61613, reliable = false)
      if user =~ /stomp:\/\/([\w\.]+):(\d+)/
        user = ""
        pass = ""
        host = $1
        port = $2
        reliable = false
      elsif user =~ /stomp:\/\/([\w\.]+):(\w+)@(\w+):(\d+)/
        user = $1
        pass = $2
        host = $3
        port = $4
        reliable = false
      end

      @id_mutex = Mutex.new
      @ids = 1
      @connection = Connection.open(user, pass, host, port, reliable)
      @listeners = {}
      @receipt_listeners = {}
      @running = true
      @replay_messages_by_txn = {}
      @listener_thread = Thread.start do
        while @running
          message = @connection.receive
          case
          when message.nil?:
            break
          when message.command == 'MESSAGE':
            if listener = @listeners[message.headers['destination']]
              listener.call(message)
            end
          when message.command == 'RECEIPT':
            if listener = @receipt_listeners[message.headers['receipt-id']]
              listener.call(message)
            end
          end
        end
      end
    end

    # Join the listener thread for this client,
    # generally used to wait for a quit signal
    def join
      @listener_thread.join
    end

    # Accepts a username (default ""), password (default ""),
    # host (default localhost), and port (default 61613)
    def self.open(user = "", pass = "", host = "localhost", port = 61613, reliable = false)
      Client.new(user, pass, host, port, reliable)
    end

    # Begin a transaction by name
    def begin(name, headers = {})
      @connection.begin(name, headers)
    end

    # Abort a transaction by name
    def abort(name, headers = {})
      @connection.abort(name, headers)

      # lets replay any ack'd messages in this transaction
      replay_list = @replay_messages_by_txn[name]
      if replay_list
        replay_list.each do |message|
          if listener = @listeners[message.headers['destination']]
            listener.call(message)
          end
        end
      end
    end

    # Commit a transaction by name
    def commit(name, headers = {})
      txn_id = headers[:transaction]
      @replay_messages_by_txn.delete(txn_id)
      @connection.commit(name, headers)
    end

    # Subscribe to a destination, must be passed a block
    # which will be used as a callback listener
    #
    # Accepts a transaction header ( :transaction => 'some_transaction_id' )
    def subscribe(destination, headers = {})
      raise "No listener given" unless block_given?
      @listeners[destination] = lambda {|msg| yield msg}
      @connection.subscribe(destination, headers)
    end

    # Unsubecribe from a channel
    def unsubscribe(name, headers = {})
      @connection.unsubscribe(name, headers)
      @listeners[name] = nil
    end

    # Acknowledge a message, used when a subscription has specified
    # client acknowledgement ( connection.subscribe "/queue/a", :ack => 'client'g
    #
    # Accepts a transaction header ( :transaction => 'some_transaction_id' )
    def acknowledge(message, headers = {})
      txn_id = headers[:transaction]
      if txn_id
        # lets keep around messages ack'd in this transaction in case we rollback
        replay_list = @replay_messages_by_txn[txn_id]
        if replay_list.nil?
          replay_list = []
          @replay_messages_by_txn[txn_id] = replay_list
        end
        replay_list << message
      end
      if block_given?
        headers['receipt'] = register_receipt_listener lambda {|r| yield r}
      end
      @connection.ack message.headers['message-id'], headers
    end

    # Send message to destination
    #
    # If a block is given a receipt will be requested and passed to the
    # block on receipt
    #
    # Accepts a transaction header ( :transaction => 'some_transaction_id' )
    def send(destination, message, headers = {})
      if block_given?
        headers['receipt'] = register_receipt_listener lambda {|r| yield r}
      end
      @connection.send(destination, message, headers)
    end

    # Is this client open?
    def open?
      @connection.open?
    end

    # Is this client closed?
    def closed?
      @connection.closed?
    end

    # Close out resources in use by this client
    def close
      @connection.disconnect
      @running = false
    end

    private
    def register_receipt_listener(listener)
      id = -1
      @id_mutex.synchronize do
        id = @ids.to_s
        @ids = @ids.succ
      end
      @receipt_listeners[id] = listener
      id
    end

  end
end

