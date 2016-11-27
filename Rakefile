require 'fileutils'
require 'pathname' # TODO: use it!

task default: [:all]

def ext(fn, newext)
  fn.sub(/\.[^.]+$/, ".#{newext}")
end

def compile(_in, _out)
  sh "ruby script/compile #{_in} >> #{_out}"
end

OUTFORMATS=%w[html/fulldoc] # html/fragment
INFILES=Dir.glob('data/*/**/*.md')

task :clean do
  sh "find data/*/ -type d -exec rmdir {} \\; 2>/dev/null"
  INFILES.each do |infile|
    outfile = ext(File.basename(infile), 'html')
    sh "find data/*/ -type f -name #{outfile} -exec rm {} \\;"
  end
end

task :all do
  INFILES.each do |infile|
    puts infile
    OUTFORMATS.each do |outformat|
      format, flavor = outformat.split('/')
      case format
        when 'html' then
          outdir = File.dirname(infile).gsub(/\/markdown/, "/#{outformat}")
          outfile = File.join(outdir, ext(File.basename(infile), format))
          FileUtils.mkdir_p outdir
          sh "echo -n > #{outfile}" # TODO: Only clear if changed, or something...
          case flavor
            when 'fragment' then
              compile(infile, outfile)
            when 'fulldoc'  then
              fragdir = outdir.gsub(/fulldoc(\/[a-z]{2}|)/, 'fragment')
              header = File.join(fragdir, 'header.html')
              footer = File.join(fragdir, 'footer.html')
              sh "cat #{header} > #{outfile}"
              compile(infile, outfile)
              sh "cat #{footer} >> #{outfile}"
          end
      end
    end
  end
end
