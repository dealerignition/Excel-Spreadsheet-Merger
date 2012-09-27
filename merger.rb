require 'csv'
require 'readline'

def conflict_resolve(column, first_value, second_value)
  puts "A conflict has been detected for the #{column} column.  Options: "
  puts "1) #{first_value}"
  puts "2) #{second_value}"
  choice = Readline.readline("Please select a value to use (1|2): ").chomp
  return choice == 1 ? first_value : second_value
end

dealers = {}
new_dealer = { name: 0, websites: 0, address: "", city: "", state: "", postal: "", owners: 0, contacts: 0, primary_email: "", other_emails: 0 }

max_names = 0
max_websites = 0
max_owners = 0
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
puts "Auto-Overriding: This CSV will automatically override the other CSV.  To manually review enter 'n' without the quotes.  Otherwise, enter the number of the trusted CSV."
override_csv = Readline.readline("Override (1|2[d]|n): ").chomp
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
      if override_csv == 'n'
        if dealers[row["phone"]]["address"].to_s != row["address"].to_s and not row["address"].to_s.empty?
          dealers[row["phone"]]["address"] = conflict_resolve("address", dealers[row["phone"]]["address"], row["address"])
        end
        if dealers[row["phone"]]["city"].to_s != row["city"].to_s and not row["city"].to_s.empty?
          dealers[row["phone"]]["city"] = conflict_resolve("city", dealers[row["phone"]]["city"], row["city"])
        end
        if dealers[row["phone"]]["state"].to_s != row["state"].to_s and not row["state"].to_s.empty?
          dealers[row["phone"]]["state"] = conflict_resolve("state", dealers[row["phone"]]["state"], row["state"])
        end
        if dealers[row["phone"]]["postal"].to_s != row["postal"].to_s and not row["postal"].to_s.empty?
          dealers[row["phone"]]["postal"] = conflict_resolve("postal", dealers[row["phone"]]["postal"], row["postal"])
        end
        if dealers[row["phone"]]["primary_email"].to_s != row["primary_email"].to_s and not row["primary_email"].to_s.empty?
          dealers[row["phone"]]["primary_email"] = conflict_resolve("primary_email", dealers[row["phone"]]["primary_email"], row["primary_email"])
        end
      else
        if override_csv == 1 and csv != first_csv
          # do nothing
        else
          dealers[row["phone"]]["address"] = row["address"]
          dealers[row["phone"]]["city"] = row["city"]
          dealers[row["phone"]]["state"] = row["state"]
          dealers[row["phone"]]["postal"] = row["postal"]
          dealers[row["phone"]]["primary_email"] = row["primary_email"]
        end
      end
      if not dealers[row["phone"]]["source_list"].to_s.empty?
        if first_csv == csv 
          dealers[row["phone"]]["source_list"] += ",#{(first_provider != "i" ? first_provider : row["sources"])}"
        else
          dealers[row["phone"]]["source_list"] += ",#{(second_provider != "i" ? second_provider : row["sources"])}"
        end
     end
      if not row["name"].to_s.empty?
        if not dealers[row["phone"]]["names_list"].to_s.empty?
          dealers[row["phone"]]["names_list"] += ",#{row["name"]}"
        else
          dealers[row["phone"]]["names_list"] = "#{row["name"]}"
        end
      end
      if not row["websites"].to_s.empty?
        if not dealers[row["phone"]]["websites_list"].to_s.empty?
          dealers[row["phone"]]["websites_list"] += ",#{row["websites"]}"
        else
          dealers[row["phone"]]["websites_list"] = "#{row["websites"]}"
        end
      end
      if not row["owners"].to_s.empty?
        if not dealers[row["phone"]]["owners_list"].to_s.empty?
          dealers[row["phone"]]["owners_list"] += ",#{row["owners"]}"
        else
          dealers[row["phone"]]["owners_list"] = "#{row["owners"]}"
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
      dealers[row["phone"]]["primary_email"] = row["primary_email"]
      if first_csv == csv
        dealers[row["phone"]]["source_list"] = (first_provider != "i" ? first_provider : row["sources"])
      else
        dealers[row["phone"]]["source_list"] = (second_provider != "i" ? second_provider : row["sources"])
      end
      if not row["name"].to_s.empty?
        dealers[row["phone"]]["names_list"] = "#{row["name"]}"
      end
      if not row["websites"].to_s.empty?
        dealers[row["phone"]]["websites_list"] = "#{row["websites"]}"
      end
      if not row["owners"].to_s.empty?
        dealers[row["phone"]]["owners_list"] = "#{row["owners"]}"
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
  max_names = dealer["names_list"].split(",").count if (dealer["names_list"].to_s != "" and dealer["names_list"].split(",").count > max_names)
  max_websites = dealer["websites_list"].split(",").count if (dealer["websites_list"].to_s != "" and dealer["websites_list"].split(",").count > max_websites)
  max_owners = dealer["owners_list"].split(",").count if (dealer["owners_list"].to_s != "" and dealer["owners_list"].split(",").count > max_owners)
  max_contacts = dealer["contacts_list"].split(",").count if (dealer["contacts_list"].to_s != "" and dealer["contacts_list"].split(",").count > max_contacts)
  max_other_emails = dealer["other_emails_list"].split(",").count if (dealer["other_emails_list"].to_s != "" and dealer["other_emails_list"].split(",").count > max_other_emails)
end

if coalesce == 'n'
  print "phone,address,city,state,postal,primary_email"
  print ",sources_count"
  (1..max_sources).each do |ct|
    print ",source#{ct}"
  end
  print ",names_count"
  (1..max_names).each do |ct|
    print ",name#{ct}"
  end
  print ",owners_count"
  (1..max_owners).each do |ct|
    if split_names == 'y'
      print ",owner_first_name#{ct},owner_last_name#{ct}"
    else
      print ",owner#{ct}"
    end
  end
  print",contacts_count"
  (1..max_contacts).each do |ct|
    if split_names == 'y'
      print ",contact_first_name#{ct},contact_last_name#{ct}"
    else
      print ",contact#{ct}"
    end
  end
  print ",other_emails_count"
  (1..max_other_emails).each do |ct|
    print ",other_email#{ct}"
  end
  print ",websites_count"
  (1..max_websites).each do |ct|
    print ",website#{ct}"
  end
  puts
else 
  puts "phone,name,address,city,state,postal,primary_email,owners,contacts,other_emails,websites,sources"
end

dealers.each_key do |key|
  dealer = dealers[key]

  if coalesce == 'n'
    print "#{key},\"#{dealer["address"]}\",\"#{dealer["city"]}\",\"#{dealer["state"]}\",\"#{dealer["postal"]}\",\"#{dealer["primary_email"]}\""
    print ",#{dealer["source_list"].to_s.empty? ? 0 : dealer["source_list"].split(',').count}"
    (1..max_sources).each do |ct|
       if ct <= (dealer["source_list"].to_s.empty? ? 0 : dealer["source_list"].split(',').count)
        print ",\"#{dealer["source_list"].split(',')[ct-1]}\""
      else
        print ","
      end
    end
    print ",#{dealer["names_list"].to_s.empty? ? 0 : dealer["names_list"].split(',').count}"
    (1..max_names).each do |ct|
       if ct <= (dealer["names_list"].to_s.empty? ? 0 : dealer["names_list"].split(',').count)
        print ",\"#{dealer["names_list"].split(',')[ct-1]}\""
      else
        print ","
      end
    end
    print ",#{dealer["owners_list"].to_s.empty? ? 0 : dealer["owners_list"].split(',').count}"
    (1..max_owners).each do |ct|
      if ct <= (dealer["owners_list"].to_s.empty? ? 0 : dealer["owners_list"].split(',').count)
        if split_names == 'y'
          print ",\"#{dealer["owners_list"].split(',')[ct-1].split(" ")[0]}\",\"#{dealer["owners_list"].split(',')[ct-1].split(" ")[1]}\""
        else
          print ",\"#{dealer["owners_list"].split(',')[ct-1]}\""
        end
      else
        if split_names == 'y'
          print ",,"
        else
          print ","
        end
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
    print ",#{dealer["websites_list"].to_s.empty? ? 0 : dealer["websites_list"].split(',').count}"
    (1..max_websites).each do |ct|
      if ct <= (dealer["websites_list"].to_s.empty? ? 0 : dealer["websites_list"].split(',').count)
        print ",\"#{dealer["websites_list"].split(',')[ct-1]}\""
      else
        print ","
      end
    end
    puts
  else 
    puts "#{key},\"#{dealer["names_list"]}\",\"#{dealer["address"]}\",\"#{dealer["city"]}\",\"#{dealer["state"]}\",\"#{dealer["postal"]}\",\"#{dealer["primary_email"]}\",\"#{dealer["owners_list"]}\",\"#{dealer["contacts_list"]}\",\"#{dealer["other_emails_list"]}\",\"#{dealer["websites_list"]}\",\"#{dealer["source_list"]}\""
  end
end
