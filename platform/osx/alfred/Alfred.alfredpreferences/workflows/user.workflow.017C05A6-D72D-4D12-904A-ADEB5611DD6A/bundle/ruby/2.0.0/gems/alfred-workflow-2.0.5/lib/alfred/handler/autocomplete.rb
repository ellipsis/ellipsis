require 'alfred/handler'
require 'fuzzy_match'

module Alfred
  module Handler

    class Autocomplete < Base
      def initialize(alfred, opts = {})
        super
        @settings = {
          :handler        => 'Autocomplete' ,
          :items          => {}             ,
          :fuzzy_score    => 0.5            ,
        }.update(opts)

        if @settings[:items].empty?
          @load_from_workflow_setting = true
        else
          @load_from_workflow_setting = false
        end
      end



      def on_feedback
        if @load_from_workflow_setting
          @settings[:items].merge! @core.workflow_setting[:autocomplete]
        end

        before, option, tail = @core.last_option

        base_item ={
          :match?   => :always_match?      ,
          :subtitle => "↩ to autocomplete" ,
          :valid    => 'no'                ,
          :icon     => ::Alfred::Feedback.CoreServicesIcon('ForwardArrowIcon') ,
        }

        if @settings[:items].has_key? tail
          unify_items(@settings[:items][tail]).each do |item|
            base_item[:autocomplete] = "#{(before + [tail, item[:complete]]).join(' ')} "
            feedback.add_item(base_item.update(item))
          end
        else
          add_fuzzy_match_feedback(unify_items(@settings[:items][option]),
                                   before, tail, base_item, feedback)
        end
      end


      def add_fuzzy_match_feedback(items, before, query, base_item, to_feedback)
        matcher = FuzzyMatch.new(items, :read => :complete)
        matcher.find_all_with_score(query).each do |item, dice_similar, leven_similar|
          next if item[:complete].size < query.size

          if (item[:complete].start_with?(query) or
              dice_similar > @settings[:fuzzy_score] or
              leven_similar > @settings[:fuzzy_score])

            base_item[:autocomplete] = "#{(before + [item[:complete]]).join(' ')} "
            to_feedback.add_item(base_item.update(item))
          end
        end
      end

      def unify_items(items)
        return [] unless items
        items.map do |item|
          if item.is_a? String
            {:title => item, :complete => item}
          elsif item.is_a? Hash
            unless item.has_key? :complete
              item[:complete] = item[:title]
            end
            item
          else
            raise InvalidArgument, "autocomplete handler can only accept string or hash"
          end
        end
      end

    end
  end
end
