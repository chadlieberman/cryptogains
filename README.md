# cryptogains
Utilities for calculating capital gains/losses on crypto transactions

If you have been trading cryptocurrencies and you are a resident of the US, you may be liable for short- and long-term capital gains taxes. The utilities included here will help you calculate your capital gains or losses.

The `fifo.coffee` script uses the FIFO (first in, first out) method of accounting. It also considers every transaction between two different cryptocurrencies as a taxable event. (Treating these as "like-kind" exchanges may be allowable for FY2017 but the IRS may also come back around with massive penalties later on.)

The script operates on a csv of transactions. Each transaction must contain the following fields: datetime, origin_wallet, origin_asset, origin_quantity, destination_wallet, destination_asset, destination_quantity, usd_value. See the `sample-transactions.csv` file for an example. It is important that the USD value provided for each transaction represent the value of the exchange in USD to the best of your ability, which in some cases means digging back in an online widget.

Once your transactions are in order, save them as `transactions.csv` and run `coffee fifo.coffee` to calculate your short-term and long-term capital gains. These will be exported to `short_gains.csv` and `long_gains.csv`, respectively. The results are in the format required for IRS Form 8949.

DISCLAIMER: I am not an accountant or a tax attorney. The codes provided herein are provided strictly AS IS and I represent no warranty for their accuracy or the resulting capital gains calculations. If you choose to use this code to determine your capital gains/losses, you do so at your own risk and indemnify me from any legal action whatsoever.
