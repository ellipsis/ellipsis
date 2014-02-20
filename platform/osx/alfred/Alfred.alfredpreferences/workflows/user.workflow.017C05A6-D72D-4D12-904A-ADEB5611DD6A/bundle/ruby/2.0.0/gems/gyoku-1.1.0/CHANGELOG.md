## 1.1.0 (2013-07-26)

* Feature: [#30](https://github.com/savonrb/gyoku/pull/30) support for building Arrays
  of parent tags using @attributes.

* Fix: [#21](https://github.com/savonrb/gyoku/pull/21) stop modifying the original Hash.
  The original issue is [savonrb/savon#410](https://github.com/savonrb/savon/issues/410).

## 1.0.0 (2012-12-17)

* Refactoring: Removed the global configuration. This should really only affect the
  `Gyoku.convert_symbols_to` shortcut which was removed as well. If you're using Gyoku
  with Savon 2.0, there's now an option for that. If you're using Gyoku on itself,
  you can pass it the `:key_converter` option instead.

## 0.5.0 (2012-12-15)

Feature: [#19](https://github.com/savonrb/gyoku/pull/19) adds support for explicit XML attributes.

Feature: [#17](https://github.com/savonrb/gyoku/pull/17) adds an `:upcase` formula.

## 0.4.6 (2012-06-28)

* Fix: [#16](https://github.com/rubiii/gyoku/issues/16) Date objects were mapped like DateTime objects.

      Gyoku.xml(date: Date.today)  # => "<date>2012-06-28</date>"

* Fix: Time objects were also mapped like DateTime objects.

      Gyoku.xml(time: sunday)  # => "<time>16:22:33</time>"

## 0.4.5 (2012-05-28)

* Fix: [issue 8](https://github.com/rubiii/gyoku/issues/8) -
  Conflict between camelcase methods in Rails.

* Fix: [pull request 15](https://github.com/rubiii/gyoku/pull/15) -
  Gyoku generates blank attribute values if there are fewer attribute
  values in attributes! than elements.

* Fix: [issue 12](https://github.com/rubiii/gyoku/issues/12) -
  Don't remove special keys from the original Hash.

## 0.4.4

* Fix: [issue 6](https://github.com/rubiii/gyoku/issues/6) -
  `Gyoku.xml` does not modify the original Hash.

## 0.4.3

* Fix: Make sure `require "date"` when necessary.

## 0.4.2

* Fix: `Array.to_xml` so that the given :namespace is applied to every element
  in an Array.

## 0.4.1

* Fix: Alternative formulas and namespaces.

## 0.4.0

* Feature: Added alternative Symbol conversion formulas. You can choose between
  :lower_camelcase (the default), :camelcase and :none.

      Gyoku.convert_symbols_to :camelcase

  You can even define your own formula:

      Gyoku.convert_symbols_to { |key| key.upcase }

## 0.3.1

* Feature: Gyoku now calls Proc objects and converts their return value.

## 0.3.0

* Feature: Now when all Hash keys need to be namespaced (like with
  elementFormDefault), you can use options to to trigger this behavior.

      Gyoku.xml hash,
        :element_form_default => :qualified,
        :namespace => :v2

## 0.2.0

* Feature: Added support for self-closing tags. Hash keys ending with a forward
  slash (regardless of their value) are now converted to self-closing tags.

## 0.1.1

* Fix: Allow people to use new versions of builder.

## 0.1.0

* Initial version. Gyoku was born as a core extension inside the
  [Savon](http://rubygems.org/gems/savon) library.
