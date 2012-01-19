# -*- coding: utf-8 -*-
"""
    Molokai Colorscheme
    ~~~~~~~~~~~~~~~~~~~

    Converted by Vim Colorscheme Converter
"""
from pygments.style import Style
from pygments.token import Token, Comment, Name, Keyword, Generic, Number, Operator, String

class MolokaiStyle(Style):

    background_color = '#272822'
    styles = {
        Token:              '#F8F8F2 bg:#272822',
        Generic.Deleted:    '#960050 bg:#1E0010',
        Name.Label:         'noinherit #E6DB74',
        Number:             '#AE81FF',
        Generic.Emph:       '#808080 underline',
        Keyword.Type:       'noinherit #66D9EF',
        Keyword:            '#F92672 bold',
        Generic.Error:      '#960050 bg:#1E0010',
        Generic.Output:     'noinherit #808080 bg:#222222',
        Name.Variable:      'noinherit #FD971F',
        Generic.Traceback:  '#F92672 bg:#232526 bold',
        Name.Tag:           '#F92672 bold',
        String:             '#E6DB74',
        Name.Entity:        '#66D9EF italic',
        Comment.Preproc:    '#A6E22E',
        Generic.Heading:    '#ef5939',
        Name.Exception:     '#A6E22E bold',
        Name.Function:      '#A6E22E',
        Generic.Subheading: '#ef5939',
        Generic.Inserted:   'bg:#13354A',
        Number.Float:       '#AE81FF',
        Name.Constant:      '#AE81FF bold',
        Comment:            '#75715E',
        Name.Attribute:     '#A6E22E',
        Operator.Word:      '#F92672',
    }
