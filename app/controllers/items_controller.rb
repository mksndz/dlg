class ItemsController < ApplicationController
  helper_method :sort_column, :sort_direction

  layout 'admin'

  def index

    @collections = Collection.all.order(:display_title)

    if params[:collection_id]
      @items = Item
                   .where(collection_id: params[:collection_id])
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
    else
      @items = Item
                   .order(sort_column + ' ' + sort_direction)
                   .page(params[:page])
    end

  end

  def show

    find_item

  end

  def new

    @item = Item.new
    collections_for_select

  end

  def create

    @item = Item.new item_params

    if @item.save
      redirect_to @item, notice: 'Item created'
    else
      collections_for_select
      render :new, alert: 'Error creating item'
    end

  end

  def edit

    find_item
    collections_for_select

  end

  def update

    if find_item.update(item_params)
      redirect_to @item, notice: 'Item updated'
    else
      collections_for_select
      render :edit, alert: 'Error creating item'
    end

  end

  def destroy

    if find_item.destroy
      redirect_to items_path, notice: 'Item destroyed.'
    else
      redirect_to items_path, alert: 'Item could not be destroyed.'
    end

  end

  private

  def find_item
    @item = Item.find(params[:id])
  end

  def collections_for_select
    @collections_for_select = Collection.all.collect { |c| [ "#{c.display_title} (#{c.slug}}", c.id ] }
  end

  def item_params
    remove_blank_multi_values
    params.require(:item).permit(
        :collection_id,
        :slug,
        :dpla,
        :public,
        :other_collections,
        :date_range,
        :dc_title       => [],
        :dc_format      => [],
        :dc_publisher   => [],
        :dc_identifier  => [],
        :dc_rights      => [],
        :dc_contributor => [],
        :dc_coverage_s  => [],
        :dc_coverage_t  => [],
        :dc_date        => [],
        :dc_source      => [],
        :dc_subject     => [],
        :dc_type        => [],
        :dc_description => [],
        :dc_creator     => [],
        :dc_language    => [],
        :dc_relation    => []
    )
  end

  def remove_blank_multi_values
      multi_fields.each do |f|
        params[:item][f].reject! { |v| v == '' }
      end
  end

  def multi_fields
    %w(
      dc_title
      dc_format
      dc_publisher
      dc_identifier
      dc_rights
      dc_contributor
      dc_coverage_s
      dc_coverage_t
      dc_date
      dc_source
      dc_subject
      dc_type
      dc_description
      dc_creator
      dc_language
      dc_relation
    )
  end

  def sort_column
    Item.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end

