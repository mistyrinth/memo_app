# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"

enable :method_override

def open_memo
  @memo_data = {
    title: "",
    body: ""
  }
  File.open("#{@id}.txt", "r", 0755) do |file|
    i = 0
    file.each_line do |line|
      if i < 1 then
        # title = first line
        @memo_data[:title] = line
      else
        # body = after first line
        pp line
        @memo_data[:body] += line
      end
      i += 1
    end
  end
end

def update_memo(name)
  @memo_data = {
    title: params[:title],
    body: params[:body]
  }

  File.open("#{name}.txt", "w", 0755) { |f|
    if params[:title].empty? == true
      params[:title] = "NOTITLE"
    end
    f.print params[:title]
    f.print "\n"
    f.print params[:body]
  }
end

get "/" do
  @files = Dir.glob("*.txt").sort_by { |f|
    File.mtime(f)
  }
  @memos = @files.map do |file|
    File.basename(file, ".txt")
  end
  @titles = @files.map do |file|
    File.open(file, "r") { |f|
      f.gets
    }
  end
  erb :top
end

get "/new" do
  erb :new
end

post "/" do
  filename = Time.now.strftime("%Y%m%d%H%M%S%3N")
  update_memo(filename)
  erb :show
  redirect to("/#{filename}/show")
end

get "/:id" do
  @id = params[:id]
  redirect to("/#{@id}/show")
end

get "/:id/show" do
  @id = params[:id]
  open_memo
  erb :show
end

patch "/:id" do
  @id = params[:id]
  update_memo(@id)
  erb :show
  redirect to("/#{@id}/show")
end

get "/:id/edit" do
  @id = params[:id]
  open_memo
  erb :edit
end

delete "/:id" do
  @id = params[:id]
  File.delete("#{@id}.txt")
  redirect to("/")
end
