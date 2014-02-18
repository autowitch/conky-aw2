#!/usr/bin/env python

import icalendar
from dateutil import tz
import dateutil
import datetime
import time
import pytz
from dateutil.rrule import rrule, rrulestr
from dateutil.parser import parse
from compiler.ast import flatten
import argparse
import re


utc = pytz.UTC

class DateValidator(object):

    def __call__(self, string):
        if string == 'today':
            d = datetime.date.today()
            return datetime.datetime(d.year, d.month, d.day, 0, 0, 0, 0)
        elif string == 'now':
            return datetime.datetime.now()
        elif string == 'yesterday':
            return datetime.datetime.now() - datetime.timedelta(1)
        elif string == 'tomorrow':
            return datetime.datetime.now() + datetime.timedelta(1)
        else:
            try:
                date = datetime.datetime.strptime(string, '%Y%m%d').datetime()
                return date
            except ValueError:
                raise argparse.ArgumentTypeError('Invalid date: Specify "all", ',
                        '"today", "yesterday" or a date formatted as yyyyymmdd.')

def parse_args():

    """
    Process command line arguments and return an object containing them.
    Any arguments not passed will contain an entry that has the default
    value as specified by the Constants class.
    """

    parser = argparse.ArgumentParser(description='Show calendar events')

    # Date selections
    parser.add_argument('-d', '--date',
            metavar='YYYYMMDD',
            dest='date',
            type=DateValidator(),
            help='Date to run. This can be "now", "today", "yesterday" or'
                ' a date formatted as YYYYMMDD. Defaults to today\'s date. '
                'Today and yesterday are based on received date, which is '
                'the current date minus one [now]')

    parser.add_argument('-r', '--num-records',
                        default=0,
                        type=int,
                        dest='num_records',
                        help='Number of records to return (0 is no limit) [0]')

    parser.add_argument('-n', '--num-days',
                        default=5,
                        type=int,
                        dest='num_days',
                        help='Number of days to return [5]')

    fname = '/home/gold/Documents/ICS/Home.ics'
    parser.add_argument('-c', '--calendar-file',
                        type=str,
                        default=fname,
                        dest='calendar_file',
                        help='Calendar file to use. [%s]' % fname)
    parser.add_argument('-o', '--output-format',
                        type=str,
                        default='256',
                        choices=('ascii', '16', '256', 'tsv', 'conky'),
                        dest='output_format',
                        help='Output format for data.')
    parser.add_argument('-H', '--display-header',
                        action='store_true',
                        dest='display_header',
                        help='Display a header record when appropriate')

    args = parser.parse_args()
    if not args.date:
        args.date = datetime.datetime.now()

    return args


class Events(object):

    def __init__(self):
        super(Events, self).__init__()
        self.num_days = 5
        self.start = None
        self.stop = None
        self.output_format = '256'
        self.display_header = False

    def fix_date(self, date):
        if not date:
            return date
        to_zone = tz.gettz('America/Denver')
        try:
            date = utc.localize(date)
        except ValueError, e:
            date = date.astimezone(to_zone)
        return date

    def fix_weekday(self, byday):
        if not byday:
            return None

        results = []
        conversion = {
            'MO': dateutil.rrule.MO,
            'TU': dateutil.rrule.TU,
            'WE': dateutil.rrule.WE,
            'TH': dateutil.rrule.TH,
            'TH': dateutil.rrule.TH,
            'FR': dateutil.rrule.FR,
            'SA': dateutil.rrule.SA,
            'SU': dateutil.rrule.SU,
        }

        for x in byday:
            if x[0] in ['1', '2', '3', '4', '5']:
                x = x[1:]
            results.append(conversion[x])

        return results

    def fix_bysetpos(self, byday):
        bysetpos = 0
        if not byday:
            return None

        if byday[0].startswith('1'):
            bysetpos = 1
        elif byday[0].startswith('2'):
            bysetpos = 2
        elif byday[0].startswith('3'):
            bysetpos = 3
        elif byday[0].startswith('4'):
            bysetpos = 4
        elif byday[0].startswith('5'):
            bysetpos = 5

        return bysetpos

    def convert_freq(self, freq):
        if not freq:
            return None
        conversion = {
            'WEEKLY':  dateutil.rrule.WEEKLY,
            'MONTHLY': dateutil.rrule.MONTHLY
        }

        return conversion[freq[0]]

    def check_recur(self, dtstart, recur):

        freq = self.convert_freq(recur.get('freq'))
        interval = recur.get('interval')
        if interval:
            interval = interval[0]
        else:
            interval = 1
        bysetpos = self.fix_bysetpos(recur.get('byday'))

        count = recur.get('count')
        if count:
            count = count[0]
        until = recur.get('until')
        if until:
            until = self.fix_date(until[0])
        byday = self.fix_weekday(recur.get('byday'))
        rule = None
        if bysetpos:
            rule = rrule(freq,
                         dtstart=dtstart,
                         interval=interval,
                         count=count,
                         until=until,
                         bysetpos=bysetpos,
                         byweekday=byday)
        else:
            rule = rrule(freq,
                         dtstart=dtstart,
                         interval=interval,
                         count=count,
                         until=until,
                         byweekday=byday)
        dates = rule.between(self.start - datetime.timedelta(hours=1),
                             self.stop, inc=True)
        if dates:
            return dates
        return False

    def check_normal(self, dtstart, dtend):
        if dtstart >= self.start and dtstart <= self.stop:
            return True
        elif dtend >= self.start and dtend <= self.stop:
            return True
        elif dtstart < self.start and dtend > self.stop:
            return True
        return False

    def populate_record(self, event):
        data = {
            'dtstart':     self.fix_date(event.get('dtstart').dt),
            'dtend':       self.fix_date(event.get('dtend').dt),
            'description': event.get('description'),
            'summary':     event.get('summary'),
            'location':    event.get('location'),
            'status':      event.get('status'),
            'priority':    event.get('priority'),
            'organizer':   event.get('organizer'),
            'attendee':    event.get('attendee'),
            'all_day':     event.get('x-microsoft-cdo-alldayevent'),
            'recurrence':  event.get('recurrence-id'),
            'created':     event.get('created'),
            'duration':    self.fix_date(event.get('dtend').dt) -
            self.fix_date(event.get('dtstart').dt),
            'recurring':   False
        }
        return data

    def process_event(self, event):
        try:
            dtstart = self.fix_date(event.get('dtstart').dt)
            dtend = self.fix_date(event.get('dtend').dt)
            events = []
            recur = event.get('rrule')
            if recur:
                dates = self.check_recur(dtstart, recur)
                if dates:
                    for event_date in dates:
                        record = self.populate_record(event)
                        record['dtstart'] = event_date
                        record['dtend'] = event_date + record['duration']
                        record['recurring'] = True
                        events.append(record)

            elif self.check_normal(dtstart, dtend):
                events.append(self.populate_record(event))
            return events
        except AttributeError, e:
            return None

    def date_compare(self, x, y):
        if x['dtstart'] < y['dtstart']:
            return -1
        elif x['dtstart'] > y['dtstart']:
            return 1
        return 0

    def strfdelta(self, tdelta, fmt):
        d = {"days": tdelta.days}
        d["hours"], rem = divmod(tdelta.seconds, 3600)
        d["minutes"], d["seconds"] = divmod(rem, 60)
        return fmt.format(**d)

    def date_to_str(self, date):
        return date.strftime('%c')

    def output_record(self, event):
        duration = self.strfdelta(event['duration'],
                                    "{hours}:{minutes:02d}")
        if event['duration'].days:
            duration = '%d days' % event['duration'].days
        summary = event['summary']
        summary = re.sub('^Inbox Measurement ', '', summary)
        summary = re.sub('^Inbox Insight ', '', summary)
        summary = re.sub('#', '', summary)
        now = datetime.datetime.now()
        now = utc.localize(now)
        current = ''
        if event['dtstart'] <= now and event['dtend'] >= now:
            current = '*'
        organizer = event['organizer'].replace('mailto:', '')
        created = event['created']
        if created:
            created = event['created'].dt.strftime('%Y.%m.%d %I:%M%p')
        else:
            created = 'Unknown'
        attendee = ', '.join(map(lambda x: x.replace('mailto:', ''),
                                 event['attendee']))

        location = event['location']
        if location:
            location = re.sub('#', '', location)
            location = re.sub('Conf CO ', '', location)
            location = re.sub('Conf ', '', location)
            if location == 'IM Lab (Macaque)':
                location = 'II Lab'
        else:
            location = 'None'

        if self.output_format == 'conky':
            event_color = '8'
            if event['dtstart'] <= now and event['dtend'] >= now:
                event_color = '9'
            try:
                print "${color0}${goto 5}${color%s}%-19.19s${color0} - " \
                    "${color6}%-7.7s${color0}@${color5}%-10.10s " \
                    "${color7}%s" % \
                    (event_color,
                     event['dtstart'].strftime('%a %b %d, %I:%M%p'),
                     duration,
                     location,
                     summary.encode('utf8'))
            except Exception, e:
                print "Unknown"

        elif self.output_format == 'tsv':
            print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % \
                (current,
                 event['dtstart'].strftime('%Y.%m.%d %I:%M%p'),
                 event['dtend'].strftime('%Y.%m.%d %I:%M%p'),
                 duration,
                 summary.encode('utf8'),
                 location,
                 event['status'],
                 event['priority'],
                 organizer,
                 event['all_day'],
                 event['recurring'],
                 created,
                 attendee)
        else:
            print event['dtstart'], event['dtend'], event['duration'], \
                event['summary']

    def main(self):
        """docstring for main"""
        # fname = '/home/gold/Documents/ICS/Home.ics'
        args = parse_args()
        fname = args.calendar_file
        self.output_format = args.output_format
        self.display_header = args.display_header
        self.start = args.date
        self.start = utc.localize(self.start)
        self.stop = args.date + datetime.timedelta(args.num_days)
        self.stop = utc.localize(self.stop)

        cal = icalendar.Calendar.from_ical(open(fname, 'rb').read())

        events = []
        for event in cal.walk('vevent'):
            new_event = self.process_event(event)
            if new_event:
                events.append(new_event)
        events = flatten(events)
        events = sorted(events, cmp=self.date_compare)

        count = 0
        if self.output_format == 'tsv' and self.display_header:
            print "current\tdtstart\tdtend\tduration\tsummary\tlocation\t" \
                "status\tpriority\torganizer\tall day\trecurring\tcreated\t" \
                "attendees"
        for x in events:
            count += 1
            if args.num_records != 0 and count > args.num_records:
                break
            self.output_record(x)


def main():
    """docstring for main"""
    events = Events()
    events.main()

if __name__ == '__main__':
    main()
