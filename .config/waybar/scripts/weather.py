#!/usr/bin/env python

import subprocess
from pyquery import PyQuery  # install using `pip install pyquery`
import json
import os
# weather icons
weather_icons = {
    "sunnyDay": "",
    "clearNight": "",
    "cloudyFoggyDay": "",
    "cloudyFoggyNight": "",
    "rainyDay": "",
    "rainyNight": "",
    "snowyIcyDay": "",
    "snowyIcyNight": "",
    "severe": "",
    "default": "",
}

# get location_id
# to get your own location_id, go to https://weather.com & search your location.

# Get location_id from environment variable
location_id = os.getenv('WEATHER_LOCATION_ID')

# If environment variable is not set, use a default value
if not location_id:
    # print waybar module data
    out_data = {
        "text": f" WEATHER_LOCATION_ID NOT FOUND",
        "alt": "",
        "tooltip": "",
        "class": "",
    }
    #location_id = "7912d03017522301f5c89f4f1d661d18ad10926c15063cf520ee5ec7ce7c787c"  # Default value
    print("Warning: WEATHER_LOCATION_ID not set. Using default value.")
else:
    #priv_env_cmd = 'cat $location_id | grep weather_location | cut -d "=" -f 2'
    #location_id = subprocess.run(priv_env_cmd, shell=True, capture_output=True).stdout.decode('utf8').strip()
    
    # get html page
    url = "https://weather.com/en-IN/weather/today/l/" + location_id
    html_data = PyQuery(url=url)
    
    # current temperature
    temp = html_data("span[data-testid='TemperatureValue']").eq(0).text()
    # print(temp)
    
    # current status phrase
    status = html_data("div[data-testid='wxPhrase']").text()
    status = f"{status[:16]}.." if len(status) > 17 else status
    # print(status)
    
    # status code
    status_code = html_data("#regionHeader").attr("class").split(" ")[2].split("-")[2]
    # print(status_code)
    
    # status icon
    icon = (
        weather_icons[status_code]
        if status_code in weather_icons
        else weather_icons["default"]
    )
    # print(icon)
    
    # temperature feels like
    temp_feel = html_data(
        "div[data-testid='FeelsLikeSection'] > span > span[data-testid='TemperatureValue']"
    ).text()
    temp_feel_text = f"Feels like {temp_feel}c"
    # print(temp_feel_text)
    
    # min-max temperature
    temp_min = (
        html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
        .eq(0)
        .text()
    )
    temp_max = (
        html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
        .eq(1)
        .text()
    )
    temp_min_max = f"  {temp_min}\t\t  {temp_max}"
    # print(temp_min_max)
    
    # wind speed
    wind_speed = html_data("span[data-testid='Wind']").text().split("\n")[1]
    wind_text = f"煮  {wind_speed}"
    # print(wind_text)
    
    # humidity
    humidity = html_data("span[data-testid='PercentageValue']").text()
    humidity_text = f"  {humidity}"
    # print(humidity_text)
    
    # visibility
    visbility = html_data("span[data-testid='VisibilityValue']").text()
    visbility_text = f"  {visbility}"
    # print(visbility_text)
    
    # air quality index
    air_quality_index = html_data("text[data-testid='DonutChartValue']").text()
    # print(air_quality_index)
    
    # hourly rain prediction
    prediction = html_data("section[aria-label='Hourly Forecast']")(
        "div[data-testid='SegmentPrecipPercentage'] > span"
    ).text()
    prediction = prediction.replace("Chance of Rain", "")
    prediction = f"\n\n    (hourly) {prediction}" if len(prediction) > 0 else prediction
    # print(prediction)
    
    # tooltip text
    tooltip_text = str.format(
        "\t\t{}\t\t\n{}\n{}\n{}\n\n{}\n{}\n{}{}",
        f'<span size="xx-large">{temp}</span>',
        f"<big>{icon}</big>",
        f"<big>{status}</big>",
        f"<small>{temp_feel_text}</small>",
        f"<big>{temp_min_max}</big>",
        f"{wind_text}\t{humidity_text}",
        f"{visbility_text}\tAQI {air_quality_index}",
        f"<i>{prediction}</i>",
    )
    
    # print waybar module data
    out_data = {
        "text": f"{icon}   {temp}",
        "alt": status,
        "tooltip": tooltip_text,
        "class": status_code,
    }
print(json.dumps(out_data))
