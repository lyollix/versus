require 'terminal-table'

args = {}
for arg in ARGV do
    t = arg.split('=')
    args[t[0][2..t[0].length]]=t[1].to_i
end

filenames = Dir.entries("rap-battles")

temp = {}
round = []
filenames.drop(2).sort.each do |file_name|    
    x = file_name.scan(/(\s*[\wа-яА-ЯёЁ\-\|'\(\)\. *]+)\s*(vs|против)/).flatten[0]
    x = file_name.split('VS',2)[0] if (!x)
    x.strip!
    i = x.split(' ').map{|x| x[0..2].downcase}.join('')
    
    file = File.open("rap-battles/#{file_name}");
    
    text = file.read
    
    round = text.split(/[Р|р]аунд \d+\.*/)
    round = [] if !round

    if round.length > 1 then
       round = round[1..round.length-1]
    end
    
    round.each do |y|
        y = y.split(/\n/)
        
        if round.length>1 then
           y = y[1..y.length-1]
           y = y[1..y.length-1] if y[0][0]='('
        end

        temp[i] = [x, []] if ! temp[i]
        temp[i] = [x, temp[i][1].append(y).flatten]
    end
end

w = {}

temp.values.each do |x|
    w[x[0]] = x[1].join(' ').scan(/[\wа-яА-ЯёЁ*]+/).select{|x| x.length > 3}.length
end

rows = []
w.each do |k,v| 
    rows << [k,v]
end

rows.sort_by! {|x| x[1]}
rows.reverse!

table = Terminal::Table.new :rows => rows
puts table
