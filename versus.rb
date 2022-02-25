require 'terminal-table'
require 'russian'
require 'russian_obscenity'

args = {}
for arg in ARGV do
    t = arg.split('=')
    args[t[0][2..t[0].length]]=t[1].to_i
end

filenames = Dir.entries("rap-battles")

battles = {}
rounds = {}
temp = {}
filenames.drop(2).sort.each do |file_name|    
    x = file_name.scan(/(\s*[\wа-яА-ЯёЁ\-\|'\(\)\. *]+)\s*(vs|против)/).flatten[0]
    x = file_name.split('VS',2)[0] if (!x)
    x.strip!
    i = x.split(' ').map{|x| x[0..2].downcase}.join('')
    
    file = File.open("rap-battles/#{file_name}");
    text = file.readlines.map(&:chomp).join(' ')
    words = text.scan(/[\wа-яА-ЯёЁ*]+/)

    bad_words = []
    words.each do |word|
        if word.include?('*') || RussianObscenity.obscene?(word)
           word.downcase!
           bad_words << word if (!bad_words.include?(word))
        end    
    end
    temp[i] = [x, 0] if !temp[i]
    temp[i] = [x, temp[i][1] + bad_words.length]
    battles[i] = [x, 0] if !battles[i]
    rounds[i] = [x, 0] if !rounds[i]
    r = text.scan(/[Рр]аунд \d/).length
    r = 1 if r == 0
    battles[i] = [x, battles[i][1] + 1]
    rounds[i] = [x, rounds[i][1] + r]
end

d=[]
temp.each do |k,v|
    x = [v, rounds[k], battles[k][1]].flatten
    d << [x[0],x[4],x[3],x[1]]
end

d.sort_by! {|x| x[3]}
d.reverse!

rows = []
for x in d.first(args['top-bad-words']) do
    b = Russian.p(x[1], "баттл", "баттла", "баттлов")
    r = Russian.p(x[2], "раунд", "раунда", "раундов")
    w = Russian.p(x[3], "нецензурное слово", "нецензурных слова", "нецензурных слов")
    qb = sprintf("%0.02f", x[3].to_f / x[1])
    qr = sprintf("%0.02f", x[3].to_f / x[2])
    rows << [x[0],"#{x[1]} #{b}", "#{x[2]} #{r}", "#{x[3]} #{w}", "#{qb} сл/баттл", "#{qr} сл/раунд"]
end

table = Terminal::Table.new :rows => rows
puts table
