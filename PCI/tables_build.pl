open input, "list.txt";
chomp(@inp = <input>);
#Регексп, я вызываю тебя!
@lines = map {s/"//g; split ','} @inp;
print @lines[-1];
#Второй этап закончится, когда я придумаю как сохранять отдельно по строкам