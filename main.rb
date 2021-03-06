require 'sinatra'
require 'sinatra/reloader'
require 'json'

before do
  @json_data = File.open('memo.json') do |file|
    JSON.parse(file.read)
  end
  @memos = @json_data['lists']
end

def update_json
  File.open('memo.json', 'w') do |file|
    JSON.dump(@json_data, file)
  end
end

def memo(id)
  matched_memo = ''
  @memos.each_with_index do |memo, index|
    matched_memo = memo if index.to_s == id.to_s
  end
  matched_memo
end

get '/' do
  erb :index
end

get '/details/:id' do
  @memo = memo(params[:id])
  erb :details
end

get '/new' do
  erb :new
end

post '/new' do
  last_index = 0
  @memos.each_with_index do |_memo, index|
    last_index = index + 1
  end
  new_hash = { id: last_index, title: params[:title], content: params[:content] }
  @memos = @memos.push(new_hash)
  update_json
  redirect to('/')
  erb :index
end

delete '/:id' do
  @memos.each_with_index do |_memo, index|
    @memos.delete_at(index) if index.to_s == params[:id].to_s
  end
  update_json
  redirect to('/')
  erb :index
end

get '/updates/:id' do
  @memo = memo(params[:id])
  erb :updates
end

patch '/:id' do
  new_hash = { id: params[:id].to_s, title: params[:title], content: params[:content] }
  @memos.each_with_index do |memo, index|
    if index.to_s == params[:id]
      if params[:title] != ''
        memo[:title] = new_hash[:title]
      elsif params[:content] != ''
        memo[:content] = new_hash[:content]
      end
    end
  end
  update_json
  redirect to('/')
  erb :index
end
