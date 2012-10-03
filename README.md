rbinvoice
=========

RbInvoice lets you generate PDF invoices from a Google Spreadsheet.
It's pretty obscure; you probably haven't heard of it.



Disclaimer
----------

RbInvoice is not production-ready code! I keep it on Github more for my own convenience than anything else. I do use it myself to bill clients, but lots of things are hard-coded, like my company address. If you use it, you do so at your own risk! I don't guarantee anything, and I don't promise any support. If you tell your clients to write checks to Paul Jungwirth and send them to my address, that's too bad for you. :-)

Perhaps someday I'll get this code into a shareable state; it's inching there a little bit each month. But right now you should find a real invoicing solution somewhere else. All documentation here is purely in expectation of an eventual release. Things may be broken and may change, so please don't take it as a promise of anything.



Input
-----

RbInvoice reads your hours from a Google Spreadsheet, which should be formatted like this:

<table>
  <tr>
    <td colspan="7"><b style="font-size:120%">My Time Tracking</b></td>
  </tr>
  <tr>
    <td><b>Weekday</b></td>
    <td><b>Day</b></td>
    <td><b>Task</b></td>
    <td><b>Notes</b></td>
    <td><b>Start</b></td>
    <td><b>Stop</b></td>
    <td><b>Total</b></td>
  </tr>
  <tr>
    <td>T</td>
    <td>3/20/2012</td>
    <td>BigCorp</td>
    <td>API</td>
    <td>8:00</td>
    <td>12:15</td>
    <td>4:15</td>
  </tr>
  <tr>
    <td>T</td>
    <td>3/20/2012</td>
    <td>SmallCorp</td>
    <td>Shopping Cart</td>
    <td>13:00</td>
    <td>17:15</td>
    <td>4:00</td>
  </tr>
</table>

Columns B, E, F, and G should have a Date format. I calculate G automatically by saying `=max(0, F3 - E3)`, but if you do that, make sure you enter times in 24-hour format, because if you work through lunch (e.g. 11:00 to 1:30) your total column will be 0:00.

