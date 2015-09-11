require 'spec_helper'
describe 'Item Search', search: true do
  describe 'Solr searching of items' do
    let(:search) do
      Item.solr_search do
        fulltext search_term
      end
    end
    before do
      Sunspot.remove_all!(Item)
      Sunspot.index!(item)
    end
    after do
      Sunspot.remove_all!(Item)
    end

    context 'searching by a keyword mentioned in language' do
      let(:language) { 'South Efate, Bislama' }
      let!(:item) { create(:item, language: language) }
      let(:search_term) { language }
      it 'should have a match' do
        expect(search.results.length).to eq 1
      end
    end

    context 'searching by identifier' do
      let(:identifier) { 'SomeWords' }
      let!(:item) { create(:item, identifier: identifier) }

      context 'using a full keyword' do
        let(:search_term) { identifier }
        it 'should have a match' do
          expect(search.results.length).to eq 1
        end
      end

      context 'using a partial keyword' do
        let(:search_term) { identifier[0..-2] }
        it 'should have a match' do
          expect(search.results.length).to eq 1
        end
      end
    end

    context 'searching by full identifier' do
      let(:identifier) { 'OtherWords' }
      let!(:item) { create(:item, identifier: identifier) }

      context 'using a full keyword' do
        let(:search_term) { item.ookii_namae }
        it 'should have a match' do
          pending 'fails even when dash is removed from ookii_namae'
          expect(search.results.length).to eq 1
        end
      end

      context 'using a partial keyword' do
        let(:search_term) { item.ookii_namae[0..-2] }
        it 'should have a match' do
          pending 'fails even when dash is removed from ookii_namae'
          expect(search.results.length).to eq 1
        end
      end
    end
  end

end