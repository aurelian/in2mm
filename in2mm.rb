require 'sinatra/base'
require 'json'
require './data'

class In2mm < Sinatra::Base
  enable :inline_templates
  set :app_file, __FILE__

  # filters
  before do
    @factor  = 81
    @formula = 25.4
  end

  # helpers
  helpers do
    def partial(page, options={})
      erb page, options.merge!(:layout => false)
    end
  end

  not_found do
    "This is nowhere to be found"
  end

  get '/' do
    erb :index
  end

  get %r{/([0-9]*\.?[0-9]+)-inches-in-mm\.(html|json)} do
    @inches     = params[:captures][0]
    @millimetres = "%0.4f" % [@inches.to_f * @formula]
    case params[:captures][1]
    when "html"
      content_type "text/html", charset: "utf-8"
      @title  = "#{@inches} inches = #{@millimetres} millimetres."
      erb :transform
    when "json"
      content_type "application/json", charset: "utf-8"
      JSON.dump({inches: @inches, millimetres: @millimetres})
    end
  end

end

__END__

@@ layout
<%= partial :meta %>
<body>
<%= partial :header %>
<%= yield %>
<%= partial :chart %>
<%= partial :footer %>
</body>

@@ transform
<h3><%= @title %></h3>

@@ index

@@ meta
<!DOCTYPE html>
<meta charset=utf-8>
<title><%= @title || "inch/mm conversion chart" %></title>
<script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
<link rel=stylesheet href="//necolas.github.io/normalize.css/3.0.2/normalize.css">
<style>
  body { font: 10pt Monaco, Consolas, monospace; background-color: #10283C; text-align: center; padding: 20px; color: #DAF8C2;}
  table { width: 800px; border-left: 1px solid #1C6B80; border-bottom:1px solid #1C6B80; text-align: center; margin:auto; }
  td, th { padding: 5px 6px; border-right: 1px solid #1C6B80;}
  th { font-weight: bold; border-bottom: 1px solid #1C6B80; border-right:1px solid #1C6B80; text-align:center; }
  tr:nth-child(2n+1) { background-color: #1F5B84; border-bottom: 1px solid #1C6B80; border-top: 1px solid #1C6B80; }
  a {color:#DAF8C2;}
  form {padding:15px;}
  input {color: #1F5B84; margin:3px;}
  footer div { padding-top: 15px; width: 800px;margin:auto; }
  footer div p { font-size:85%; text-align:right; }
  footer a { color: #49ED8D; }
  header div { width:800px;margin:auto; }
  header div h1 { font-size: 130%;}
  header div h2 { font-size: 165%; color: #BDF365; text-align:right;text-decoration:blink; margin-top:-22px; margin-right:45px; font-weight:bold;z-index:2}
</style>
<script>
  $(function() {
    $('input#inch').keyup(function() {
      try { var inches = eval($(this).val().replace(' ', '+'));
      } catch (e) { return; }
      if(inches === void 0) { return; }

      var result = (Math.round(parseFloat(inches * 25.4) * 10000) / 10000).toFixed(4);
      var title = inches + " inches = " + result + " millimetres.";

      $('h3').html(title);
      $('input#mm').val(result);

      history.pushState(null, title, "/" + inches + "-inches-in-mm.html");

    });
    $('h2').click(function(){$(this).hide();});
  });
</script>

@@ header
  <header>
    <div>
      <h1>Inches 2 MM : a conversion chart that doesn't suck</h1>
      <h2>Nor burn your retina.</h2>
      <!--
      <p>download MacOS <a href="http://locknet.ro/files/Inches2MM-1.1.wdgt.zip" title="Inches2MM - version 1.1.">dashboard widget</a>.</p>
      -->
    </div>
  </header>
  <form><input id=inch size=6><label for=inch>inches</label> = <input id=mm disabled size=9><label for=mm>mm</label></form>

@@ chart
  <table><tr><th colspan=2>inches<th>metric<th colspan=2>inches<th>metric<th colspan=2>inches<th>metric</tr><tr><td>fractional<td>decimal<td>mm<td>fractional<td>decimal<td>mm<td>fractional<td>decimal<td>mm</tr><% for i in 0..@factor %><tr><% for k in 0..2 %><% current = i + (@factor * k) + k %><td><%= Data.rows[current][:fractional].gsub('xxxx','&middot;') %><td><a href="/<%= Data.rows[current][:decimal]%>-inches-in-mm.html" title="<%= Data.rows[current][:decimal]%> inches in millimetres"><%= Data.rows[current][:decimal] %></a><td><%= "%0.4f" % (Data.rows[current][:decimal] * @formula) %><% end %></tr><% end %></table>

@@ footer
  <footer>
    <div>
      <p>
        &copy; <a href=http://locknet.ro rel=author>aurelian oancea</a> &mdash;
        source code is on <a href=http://github.com/aurelian/in2mm>github</a>
      </p>
    </div>
  </footer>
  <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

    try {
      ga('create', 'UA-320013-5', 'auto');
      ga('send', 'pageview');
    } catch(e) {

    }
  </script>

