class ItemsController < ApplicationController

  layout 'admin'

  def index

    @items = Item.all

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
        :in_georgia,
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
        :dc_description => []
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
    )
  end

end

