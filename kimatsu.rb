# -*- coding: utf-8 -*-
require 'rubygems'
require 'pp'
require 'gcalapi'
filename = ARGV[0]
user_file = open(filename)#ユーザーのデータ
titech_data = open("jikanwari.txt")#titech時間割

##メソッド開始

##何日か取得
def get_day(text)
  text =~ /^7\/(\d+)/
  return $1
end

##何限か取得
def get_time(text)
  text =~ /.+?\s(\d)-\d/
  return $1
end

##日と時限を引数にして始まるTimeを返す
def begin_time(day, time)
  day = day.to_i
  time = time.to_i
  case time
  when 1 
    return Time.mktime(2011, 7, day, 9, 0, 0)
  when 3
    return Time.mktime(2011, 7, day, 10, 45, 0)
  when 5
    return Time.mktime(2011, 7, day, 13, 20, 0)
  when 7
    return Time.mktime(2011, 7, day, 15, 5, 0)
  when 9 
    return Time.mktime(2011, 7, day, 16, 50, 0)
  end
end

##教科名
def get_subject_name(text)
  text =~ /^.+?\s.+?\s.+?\s(.+?)\s/u
  return $1
end

##講義室
def get_room(text)
  # if text =~ /^.+?\s.+?\s.+?\s.+?\s(試験|補講)(\w+?)\s/u
  if text =~ /(試験|補講)\s([\w\d]+)/u
    return $2
  end
end

##試験か補講か
def get_test_or_hokou(text)
  if text =~ /試験/u
    return "試験"
  elsif text =~ /補講/u
    return "補講"
  else
    return
  end
end

##メソッド終了

subject = []#入力を格納する配列

while user_text = user_file.gets do
  user_text.chomp!
  subject[user_file.lineno.to_i - 1] = user_text
end

# ##Googleカレンダー設定
subject.compact!
mail = subject.shift
pass = subject.shift
feed = "http://www.google.com/calendar/feeds/" + mail +  "%40gmail.com/private/full"
mail = mail + "@gmail.com"

begin
  service = GoogleCalendar::Service.new(mail, pass)
  calendar = GoogleCalendar::Calendar::new(service, feed)
rescue
  pp "can't authertication try again!"
  exit
end
# ##カレンダー設定終了

while titech_text = titech_data.gets do
  titech_text.chomp!
  subject.each { |text|
    if titech_text =~ /\s#{text}\s/
      begin
        event = calendar.create_event
        event.title = get_subject_name(titech_text) + get_test_or_hokou(titech_text)
        event.desc = ""
        event.where = get_room(titech_text)
        event.st = begin_time(get_day(titech_text), get_time(titech_text))
        event.en = begin_time(get_day(titech_text), get_time(titech_text)) + 3600*1.5
        event.save!
      rescue
        pp "fault google calender"
        exit
      end
      print "success!\n"
    end
  }
end

titech_data.close
user_file.close
