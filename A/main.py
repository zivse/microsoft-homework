import requests
import time
from const import bitcoin_api


def get_bitcoin_current_price():
    response = requests.get(bitcoin_api)
    if response.status_code == 200:
        data = response.json()
        bitcoin_current_price = data['bitcoin']['usd']
        return bitcoin_current_price
    else:
        print(f"Error: Unable to fetch data. Status code {response.status_code}")
        return None


prices = []

while True:
    price = get_bitcoin_current_price()
    if price:
        prices.append(price)
        prices = prices[-10:]
        print(f"The current price of Bitcoin is: ${price}")
        if len(prices) == 10:
            average_price = sum(prices) / len(prices)
            print(f"The average price of Bitcoin for the last 10 minutes is: ${average_price:.2f}")
            prices = []

    time.sleep(60)
