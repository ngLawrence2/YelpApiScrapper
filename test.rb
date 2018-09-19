require "json"
require "http"
require "optparse"
require_relative "apikey"

API_KEY = key
API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"

def search(term, location, offset)
  url = "#{API_HOST}#{SEARCH_PATH}"
  params = {
    term: term,
    location: location,
    limit: 3, #change to 50
    offset: offset
  }

  response = HTTP.auth("Bearer #{API_KEY}").get(url, params: params)
  businessInfo = response.parse
  # businessInfo["businesses"] #array of businesses of size limit

  business_id = businessInfo["businesses"][0]["id"]


  result = []
  businessInfo["businesses"].each do |business|
    info = {}
    info["name"]=business["name"]
    info["address"] = createReadableAddress(business)
    info["city"] = business["location"]["city"]
    info["zipCode"] = business["location"]["zip_code"]
    info["lat"] = business["coordinates"]["latitude"]
    info["lng"] = business["coordinates"]["longitude"]
    info["phone"] = business["display_phone"]
    info["price"] = business["price"]
    info["creditCard"] = randomPercentage(8,2)
    info["parking"] = randomPercentage(1,1)
    info["takeOut"] = randomPercentage(7,3)
    info["delivery"] = randomPercentage(3,7)
    info["hours"] = getHours(business["id"])
    result << info
  end
  result
end

def getHours(business_id)
  url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"
  response = HTTP.auth("Bearer #{API_KEY}").get(url)
  hours = response.parse
  parseHours(hours["hours"][0]["open"])
end


def createReadableAddress(business)
  address2 = business["location"]["address2"]
  address3 = business["location"]["address3"]
  address3 ||= ""
  address2 ||= ""
  resultAddress = business["location"]["address1"] + address2 + " " + address3
end

def parseHours(hoursArray)
  result=[]
  hoursArray.each do |hoursObject|
    openResultTime = createReadableTime(hoursObject,"start")
    closeResultTime = createReadableTime(hoursObject,"end")
    result << (openResultTime + "-" +  closeResultTime)
  end
  result
end

def createReadableTime(hoursObject, type)
  hours = hoursObject[type]
  time= hours[0..1].to_i
  minute = hours[2..-1]
  result = ""
  if time>12
    time-=12
    if time < 10
      result = "0" + time.to_s + ":" + minute.to_s + "pm"
    else
      result = time.to_s + ":" + minute.to_s + "pm"
    end
  else
    if time < 10
      result = "0" + time.to_s + ":" + minute.to_s + "am"
    else
      result = time.to_s + ":" + minute.to_s + "am"
    end
  end
  result
end


#creditCard 8,2
#parking 1,1
#takeOut 7,3
#delivery 3,7
def randomPercentage(chanceForTrue, chanceForFalse)
  total = chanceForTrue+chanceForFalse
  randomNumber = rand(total)
  return "Yes" if rand < chanceForTrue
  return "No"
end


["Chinese", "American", "Mexican", "Korean", "Italian", "French", "Fast Food" ]
index = 5
File.open("seed.txt","a") do |lineNumber|
  (0..5).each do |k|
    resultArray = search('Fast Food', 'San Francisco', k*3)
    resultArray.each do |currentBusiness|
      businessProperties = currentBusiness.keys
      resultString = "b" + index.to_s + "= Business.create("
      businessProperties.each do |property|
        if property == "hours" || property=="zipCode" || property == "lat" || property == "lng"
          resultString += property  + ": " + currentBusiness[property].to_s + ","
          next
        end
        resultString += property + ": \"" + currentBusiness[property].to_s + '", '
      end

      lineNumber.puts resultString[0..-2] + ")"
      index+=1
    end
  end
end



# create_table "businesses", force: :cascade do |t|
#   t.string "name", null: false                         businessInfo["businesses"][0]['name']
#   t.string "address", null: false

# address2 = businessInfo["businesses"][0]["location"]["address2"]
# address3 = businessInfo["businesses"][0]["location"]["address3"]
# businessInfo["businesses"][0]["location"]["address1"] + address2 + " " + address3


#   t.string "city", null: false
# businessInfo["businesses"][0]["location"]["city"]


#   t.integer "zipCode", null: false
# businessInfo["businesses"][0]["location"]["zip_code"]


#   t.float "lat", null: false
# businessInfo["businesses"][0]["coordinates"]["latitude"]

#   t.float "lng", null: false
# businessInfo["businesses"][0]["coordinates"]["longitude"]

#   t.string "phone", null: false
#   businessInfo["businesses"][0]["display_phone"]


#   t.string "price", null: false
#   businessInfo["businesses"][0]["price"]


#   t.boolean "creditCard"

# def moreCreditCard
#  rand = rand(10)
#   return true if rand>2
#   return false
# end



#   t.string "parking"

# def parking
# rand=rand(2)
# return true if rand>0
# return false
# end


#   t.boolean "takeOut"
# def takeOut
#  rand=rand(10)
#  return false if rand>7
#  return true
# end

#   t.boolean "delivery"
  # def delivery
  #   !takeOut
  # end

#
#   t.string "hours", array: true
#
# end
