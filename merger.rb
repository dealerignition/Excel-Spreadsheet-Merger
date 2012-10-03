require 'csv'
require 'readline'

dealers = {}
new_dealer = { name: "", website: "", address: "", city: "", state: "", postal: "", owner: "", contacts: 0, primary_email: "", other_emails: 0 }

max_contacts = 0
max_other_emails = 0
max_sources = 0

first_csv = Readline.readline("Enter the name of CSV 1: ").chomp
second_csv = Readline.readline("Enter the name of CSV 2: ").chomp
puts "Sources: Please specify the information provider.  If this has been specified in-sheet, enter 'i' without quotes."
first_provider = Readline.readline("Sheet 1 Provider (i|name): ").chomp
first_provider.strip!
second_provider = Readline.readline("Sheet 2 Provider (i|name): ").chomp
second_provider.strip!
puts "Coalesce: For columns for which multiple values are kept, should these be displayed in the same column?"
coalesce = Readline.readline("Coalesce (y[d]|n): ").chomp
split_names = 'n'
if coalesce == 'n'
  puts "Name Seperation: The program will attempt to separate out first and last name into for each contact."
  split_names = Readline.readline("Separate Names (y|n[d]): ").chomp
end

[first_csv, second_csv].each do |csv|
  CSV.foreach(csv, :headers => true) do |row|
    if dealers[row["phone"]]
      if not dealers[row["phone"]]["owner"] and row["owner"] and not dealers[row["phone"]]["primary_email"] and row["primary_email"]
        dealers[row["phone"]]["address"] = row["address"]
        dealers[row["phone"]]["city"] = row["city"]
        dealers[row["phone"]]["state"] = row["state"]
        dealers[row["phone"]]["postal"] = row["postal"]
        dealers[row["phone"]]["name"] = row["name"]
        dealers[row["phone"]]["website"] = row["website"]
        dealers[row["phone"]]["owner"] = row["owner"]
        dealers[row["phone"]]["primary_email"] = row["primary_email"]
      elsif not dealers[row["phone"]]["owner"] and row["owner"]
        dealers[row["phone"]]["owner"] = row["owner"]
      end
      if not dealers[row["phone"]]["source_list"].to_s.empty?
        if first_csv == csv 
          dealers[row["phone"]]["source_list"] += ",#{(first_provider != "i" ? first_provider : row["sources"])}"
        else
          dealers[row["phone"]]["source_list"] += ",#{(second_provider != "i" ? second_provider : row["sources"])}"
        end
      end
      if not row["contacts"].to_s.empty?
        if not dealers[row["phone"]]["contacts_list"].to_s.empty?
          dealers[row["phone"]]["contacts_list"] += ",#{row["contacts"]}"
        else
          dealers[row["phone"]]["contacts_list"] = "#{row["contacts"]}"
        end
      end
      if not row["other_emails"].to_s.empty?
        if not dealers[row["phone"]]["other_emails_list"].to_s.empty?
          dealers[row["phone"]]["other_emails_list"] += ",#{row["other_emails"]}"
        else
          dealers[row["phone"]]["other_emails_list"] = "#{row["other_emails"]}"
        end
      end
    else
      dealers[row["phone"]] = new_dealer.clone
      dealers[row["phone"]]["address"] = row["address"]
      dealers[row["phone"]]["city"] = row["city"]
      dealers[row["phone"]]["state"] = row["state"]
      dealers[row["phone"]]["postal"] = row["postal"]
      dealers[row["phone"]]["name"] = row["name"]
      dealers[row["phone"]]["website"] = row["website"]
      dealers[row["phone"]]["owner"] = row["owner"]
      dealers[row["phone"]]["primary_email"] = row["primary_email"]
      if first_csv == csv
        dealers[row["phone"]]["source_list"] = (first_provider != "i" ? first_provider : row["sources"])
      else
        dealers[row["phone"]]["source_list"] = (second_provider != "i" ? second_provider : row["sources"])
      end
      if not row["contacts"].to_s.empty?
        dealers[row["phone"]]["contacts_list"] = "#{row["contacts"]}"
      end
      if not row["other_emails"].to_s.empty?
        dealers[row["phone"]]["other_emails_list"] = "#{row["other_emails"]}"
      end
    end
  end
end

dealers.each_key do |key|
  dealer = dealers[key]
  max_sources = dealer["source_list"].split(",").count if (dealer["source_list"].to_s != "" and dealer["source_list"].split(",").count > max_sources)
  max_contacts = dealer["contacts_list"].split(",").count if (dealer["contacts_list"].to_s != "" and dealer["contacts_list"].split(",").count > max_contacts)
  max_other_emails = dealer["other_emails_list"].split(",").count if (dealer["other_emails_list"].to_s != "" and dealer["other_emails_list"].split(",").count > max_other_emails)
end

if coalesce == 'n'
  print "name,phone,address,city,state,postal,primary_email,website,owner"
  print ",sources_count"
  (1..max_sources).each do |ct|
    print ",source#{ct}"
  end
  print ",contacts_count"
  (1..max_contacts).each do |ct|
    print ",contact#{ct}"
  end
  print ",other_emails_count"
  (1..max_other_emails).each do |ct|
    print ",other_email#{ct}"
  end
  puts
else 
  puts "name,phone,address,city,state,postal,primary_email,owner,contacts,other_emails,website,sources"
end

dealers.each_key do |key|
  dealer = dealers[key]

  if coalesce == 'n'
    print "\"#{dealer["name"]}\",\"#{key}\",\"#{dealer["address"]}\",\"#{dealer["city"]}\",\"#{dealer["state"]}\",\"#{dealer["postal"]}\",\"#{dealer["primary_email"]}\",\"#{dealer["website"]}\",\"#{dealer["owner"]}\""
    print ",#{dealer["source_list"].to_s.empty? ? 0 : dealer["source_list"].split(',').count}"
    (1..max_sources).each do |ct|
       if ct <= (dealer["source_list"].to_s.empty? ? 0 : dealer["source_list"].split(',').count)
        print ",\"#{dealer["source_list"].split(',')[ct-1]}\""
      else
        print ","
      end
    end
    print",#{dealer["contacts_list"].to_s.empty? ? 0 : dealer["contacts_list"].split(',').count}"
    (1..max_contacts).each do |ct|
      if ct <= (dealer["contacts_list"].to_s.empty? ? 0 : dealer["contacts_list"].split(',').count)
        if split_names == 'y'
          print ",\"#{dealer["contacts_list"].split(',')[ct-1].split(" ")[0]}\",\"#{dealer["contacts_list"].split(',')[ct-1].split(" ")[1]}\""
        else
          print ",\"#{dealer["contacts_list"].split(',')[ct-1]}\""
        end
      else
        if split_names == 'y'
          print ",,"
        else
          print ","
        end
      end
    end
    print ",#{dealer["other_emails_list"].to_s.empty? ? 0 : dealer["other_emails_list"].split(',').count}"
    (1..max_other_emails).each do |ct|
      if ct <= (dealer["other_emails_list"].to_s.empty? ? 0 : dealer["other_emails_list"].split(',').count)
        print ",\"#{dealer["other_emails_list"].split(',')[ct-1]}\""
      else
        print ","
      end
    end
    puts
  else 
    puts "\"#{dealer["name"]}\",\"#{key}\",\"#{dealer["address"]}\",\"#{dealer["city"]}\",\"#{dealer["state"]}\",\"#{dealer["postal"]}\",\"#{dealer["primary_email"]}\",\"#{dealer["owner"]}\",\"#{dealer["contacts_list"]}\",\"#{dealer["other_emails_list"]}\",\"#{dealer["website"]}\",\"#{dealer["source_list"]}\""
  end
end
