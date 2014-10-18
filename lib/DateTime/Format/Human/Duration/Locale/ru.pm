package DateTime::Format::Human::Duration::Locale::ru;

use strict;
use warnings;

sub get_human_span_hashref {
    return {
        'no_oxford_comma' => 1,
	'use_5' => 1,
        'no_time' => 'прямо сейчас',
        'and'     => 'и',
        'year'  => 'год',
	'years5' => 'года',
        'years' => 'лет',
        'month'  => 'месяц',
	'month5' => 'месяца',
        'months' => 'месяцев',
        'week'  => 'неделю',
	'weeks5' => 'недели',
        'weeks' => 'недель',
        'day'  => 'день',
        'days5' => 'дня',
	'days' => 'дней',
        'hour'  => 'час',
        'hours5' => 'часа',
	'hours' => 'часов',
        'minute'  => 'минуту',
	'minute5' => 'минуты',
        'minutes' => 'минут',
        'second'  => 'секунду',
	'seconds5' => 'секунды',
        'seconds' => 'секунд',
        'nanosecond'  => 'наносекунду',
	'nanoseconds5' => 'наносекунды',
        'nanoseconds' => 'наносекунд',
    };
}

1;
