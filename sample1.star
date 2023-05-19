load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("time.star", "time")
load("cache.star", "cache")

YAHOO_FINANCE_URL = "https://query1.finance.yahoo.com/v8/finance/chart/"

WTI_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABoAAAAgCAIAAACDyf9SAAAACXBIWXMAAC4jAAAuIwF4pT92AAABVUlEQVRIie2Qv0sCYRjHv5VgCl3ndVxeQV1GGYgFTUFEIA2BDa3uTq39Je3tSXtkQ4HYEPRrKAkt1AR7ues4zxNOxIaGBy44++Xgdp/p+T7vy4f3/QIeHh4DZciZ1ncznbZxc7ZHMZHKNrTC/fm+E1klJ89t9ioujrYTqWytdPpye+BztnarHpJiNEtKEoArWo1Kt2sD4MUoJ0Qso2zqRZf6S9fQnkJSTFKSWvVkIrxMS17eMFl+cmYNQL2YoaUST3NCRH+7qz4cunTDzkRnJBLCK+/1awDi1CoATliwjPJvnfXqAHTa5ri4CMAf4A21YLcYL0Yp9v7rb51lPAfHZCWepq819RInRChWH4/71hlqAcD0/JbdYgDY6yWA2aUdAB8d1reOyvYH+KZeAmCyPIAR3yj12LcOAFVO73KiWrv6p86Nzy8H+fhP0cG1/PaOh4fHAPgEbA99rdFsXP8AAAAASUVORK5CYII=
""")

def main():
    now = time.now()
    hour = now.hour

    if (7 <= hour) and (hour < 15):
        symbol = "CL=F"
        currency = "$"
    else:
        symbol = "CL=F"
        currency = "$"

    cache_key = "share_price_" + symbol
    share_price_cached = cache.get(cache_key)

    if share_price_cached != None:
        print("Hit! Displaying cached data.")
        share_price = float(share_price_cached)
    else:
        print("Miss! Calling Yahoo Finance API.")
        rep = http.get(YAHOO_FINANCE_URL + symbol, params={"interval": "1d", "range": "1d", "indicators": "quote", "includeTimestamps": "true"})

        if rep.status_code != 200:
            fail("Yahoo Finance request failed with status %d", rep.status_code)

        response_json = rep.json()
        share_price = response_json["chart"]["result"][0]["indicators"]["quote"][0]["close"][-1]
        cache.set(cache_key, str(share_price), ttl_seconds=60)

    return render.Root(
        child=render.Box( # This Box exists to provide vertical centering
            render.Row(
                expanded=True,  # Use as much horizontal space as possible
                main_align="space_evenly",  # Controls horizontal alignment
                cross_align="center",  # Controls vertical alignment
                children=[
                    render.Image(src=WTI_ICON),
                    render.Text(currency + str(int(share_price * 100) / 100.0)),
                ],
            ),
        ),
    )
