module Veewee
  module Provider
    module Core
      module Helper

        class ShellResult
          attr_accessor :stdout
          attr_accessor :stderr
          attr_accessor :status

          def initialize(stdout,stderr,status)
            @stdout=stdout
            @stderr=stderr
            @status=status
          end
        end

        module Shell

          # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
          # This should work on windows too now
          # This will result in a ShellResult structure with stdout, stderr and status
          def shell_exec(command,options = {:mute => true,:status => 0})
            defaults={:mute => true, :status => 0}
            options=defaults.merge(options)
            result=ShellResult.new("","",-1)
            env.ui.info "Executing #{command}" unless options[:mute]
            env.logger.debug "Command: \"#{command}\""
            env.logger.debug "Output:"
            env.logger.debug "-------"
            escaped_command=command
            IO.popen("#{escaped_command}"+ " 2>&1") { |p|
              p.each_line{ |l|
                result.stdout+=l
                env.ui.info(l,{:new_line => false})  unless options[:mute]
                env.logger.debug(l.chomp)
              }
              result.status=Process.waitpid2(p.pid)[1].exitstatus
              if result.status.to_i!=options[:status]
                env.ui.error "Error: We executed a shell command and the exit status was not #{options[:status]}"
                env.ui.error "- Command :#{command}."
                env.ui.error "- Exitcode :#{result.status}."
                env.ui.error "- Output   :\n#{result.stdout}"
                raise Veewee::Error,"Wrong exit code for command #{command}"
              end
            }
            return result
          end


        end #Module
      end #Module
    end #Module
  end #Module
end #Module
