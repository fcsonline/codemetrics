require 'pry'
require 'json'

module Engines
  module Npm
    class Extractor
      METRICS = %i[
        npm_number_of_dependencies
        npm_number_of_dev_dependencies
        npm_number_of_scripts
        npm_number_of_vulnerable_dependencies
        npm_number_of_vulnerable_dependencies_low
        npm_number_of_vulnerable_dependencies_moderate
        npm_number_of_vulnerable_dependencies_high
      ].freeze

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      private

      def requirements?
        File.exist?('package.json')
      end

      def npm_number_of_dependencies
        npm_package['dependencies'].keys.length
      end

      def npm_number_of_dev_dependencies
        npm_package['devDependencies'].keys.length
      end

      def npm_number_of_scripts
        npm_package['scripts'].keys.length
      end

      def npm_number_of_vulnerable_dependencies
        npm_audit['advisories'].length
      end

      def npm_number_of_vulnerable_dependencies_low
        npm_audit_by_severity['low']
      end

      def npm_number_of_vulnerable_dependencies_moderate
        npm_audit_by_severity['moderate']
      end

      def npm_number_of_vulnerable_dependencies_high
        npm_audit_by_severity['high']
      end

      def npm_package
        @npm_package ||= JSON.parse(`cat package.json`)
      end

      def npm_audit
        @npm_audit ||= JSON.parse(`npm audit --json`)
      end

      def npm_audit_by_severity
        npm_audit['advisories'].map {|key, value| value['severity']}.inject(Hash.new(0)) { |total, e| total[e] += 1; total}
      end
    end
  end
end