# This program uses FIFO accounting and allows for like-kind
# exchanges of one cryptocurrency for another, tracking the
# cost basis from the price of the original purchase, and
# transferring that cost basis from the original token to the
# new token. Capital gains or losses events are triggered
# when a cryptocurrency is sold for USD or when a quantity is
# transferred to an account not owned by me. The cost basis
# for newly minted coins (e.g., in the event of a hard fork)
# is approximated by the closest (in time) trading value
# at or near the time of the hard fork and is represented as
# a transaction with null origin.
#
# Prices are all in USD.

fs = require 'fs'
Account = require './account'
csvToArray = require './csv-to-array'

roundToDollars = (num) ->
    Math.round(100*num)/100

#transactions = require './fake-transactions'
transactions = csvToArray 'transactions.csv'
transactions = transactions.slice(0, 100)
console.log 'transactions =', transactions

taxEventsToCsv = (tax_events, filename, type) ->
    quote = (s) -> "\"#{s}\""
    csv = 'quantity,asset,buy_date,sell_date,proceeds,cost_basis,gain\n'
    tax_events
        .filter (tax_event) ->
            time_elapsed = (Date.parse(tax_event.sell_date) - Date.parse(tax_event.buy_date))/1000/60/60/24 # days
            if time_elapsed >= 365 and type == 'long'
                return true
            else if time_elapsed < 365 and type == 'short'
                return true
            else
                return false
        .forEach (tax_event) ->
            csv += [
                tax_event.quantity
                tax_event.asset
                tax_event.buy_date
                tax_event.sell_date
                tax_event.proceeds
                tax_event.cost_basis
                tax_event.gain
            ].map(quote).join(',') + '\n'
    fs.writeFileSync filename, csv, 'utf8'

# Accounts
accounts =
    'USD': new Account 'USD', 100000
    'BTC': new Account 'BTC'
    'ETH': new Account 'ETH'
    'BCH': new Account 'BCH'
    'LTC': new Account 'LTC'
    'XRP': new Account 'XRP'

tax_events = []

sorted_transactions = transactions.sort (a, b) -> Date.parse(a.datetime) - Date.parse(b.datetime)
console.log 'sorted_transactions =', sorted_transactions

# Process transactions
transactions
    .sort (a, b) ->
        Date.parse(a.datetime) - Date.parse(b.datetime)
    .forEach (transaction) ->
        {
            datetime,
            origin_wallet,
            origin_asset,
            origin_quantity,
            destination_wallet,
            destination_asset,
            destination_quantity,
            usd_value
        } = transaction
        console.log 'transaction =', transaction
        return if origin_asset == destination_asset and origin_wallet != 'External' and destination_wallet != 'External'
        if origin_wallet != 'N/A'
            deposits = accounts[origin_asset].withdraw datetime, origin_quantity, usd_value
        accounts[destination_asset].deposit datetime, destination_quantity, usd_value
        if origin_asset != 'USD' and deposits?.length
            console.log 'deposits =', deposits
            for deposit in deposits
                proceeds = roundToDollars(usd_value * (deposit.quantity / origin_quantity))
                cost_basis = roundToDollars(deposit.usd_value)
                tax_events.push
                    quantity: deposit.quantity
                    asset: origin_asset
                    buy_date: deposit.datetime
                    sell_date: datetime
                    cost_basis: cost_basis
                    proceeds: proceeds
                    gain: roundToDollars(proceeds - cost_basis)

Object.keys(accounts).map (asset) ->
    console.log accounts[asset]
console.log ''
console.log 'tax_events =', tax_events

# Print the capital gains/losses entries to CSVs
taxEventsToCsv tax_events, 'long_gains.csv', 'long'
taxEventsToCsv tax_events, 'short_gains.csv', 'short'
