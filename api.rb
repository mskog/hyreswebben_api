require 'mechanize'
require 'dotenv'

module HyreswebbenApi
  class API < Grape::API
    format :json

    http_basic do |username, password|
      { ENV['AUTH_USERNAME'] => ENV['AUTH_PASSWORD'] }[username] == password
    end

    get "/" do
      a = Mechanize.new

      a.get("http://www.hyreswebben.se/#{ENV['HYRESWEBBEN_BRF']}/Login.aspx") do |page|
        page.form_with(id: "Form1") do |form|
          form.strUser = ENV["HYRESWEBBEN_USERNAME"]
          form.strPW = ENV["HYRESWEBBEN_PASSWORD"]
        end.click_button
      end

      data_page = a.get("http://www.hyreswebben.se/#{ENV['HYRESWEBBEN_BRF']}/StartSensorCurrent.aspx")

      {
        electricity: data_page.at_css("[name='txtEl']")["value"],
        hot_water: data_page.at_css("[name='txtVV']")["value"],
        heat: data_page.at_css("[name='txtVMM']")["value"],
      }
    end
  end
end
