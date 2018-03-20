
class Deposit
    constructor: (@datetime, @quantity, @usd_value) ->
        @remaining_quantity = @quantity

    claim: (quantity) ->
        if quantity > @remaining_quantity
            throw 'Not enough quantity remaining'
        else
            @remaining_quantity -= quantity

module.exports = class Account
    constructor: (@name, @balance=0.0) ->
        @deposits = []
        if @balance > 0.0
            @deposits.push new Deposit '2000-01-01', @balance, @balance

    deposit: (datetime, quantity, usd_value) ->
        @deposits.push new Deposit datetime, quantity, usd_value
        @balance += quantity

    withdraw: (datetime, quantity, usd_value) ->
        candidates = @deposits.filter (d) -> d.remaining_quantity > 0
        deposits = []
        for candidate in candidates
            if candidate.datetime > datetime
                throw 'Candidate is in the future!'
            sold_quantity = Math.min candidate.remaining_quantity, quantity
            deposit =
                datetime: candidate.datetime
                usd_value: candidate.usd_value * (sold_quantity / candidate.quantity)
                quantity: sold_quantity
            deposits.push deposit
            candidate.claim sold_quantity
            quantity -= sold_quantity
            @balance -= sold_quantity
            if quantity <= 0
                break
        return deposits

