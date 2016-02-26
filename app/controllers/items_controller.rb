class ItemsController < ApplicationController
  include DcHelper

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

  def copy

    # here we create a new db record then load the edit form
    # an alternative would be to not save the entity yet, but load the new form
    # with the attributes from the item to be 'copied'

    find_item

    item_attrs = @item.attributes.except('id')
    item_attrs['slug'] << '-copy'

    @copy = Item.new(item_attrs)

    respond_to do |format|
      if @copy.save
        format.html { redirect_to edit_item_path(@copy), notice: 'Item copy was successfully created.' }
        format.json { render :show, status: :created, location: @copy }
      else
        format.html { redirect_to @item, alert: @copy.errors }
        format.json { render json: @copy.errors, status: :unprocessable_entity }
      end
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

  def collections_for_select
    @collections = Collection.all.order(:display_title)
  end

  def find_item
    @item = Item.find(params[:id])
  end

  def item_params
    prepare_params
    params.require(:item).permit(
        :collection_id,
        :slug,
        :dpla,
        :public,
        :date_range,
        :other_collections  => [],
        :dc_title           => [],
        :dc_format          => [],
        :dc_publisher       => [],
        :dc_identifier      => [],
        :dc_rights          => [],
        :dc_contributor     => [],
        :dc_coverage_s      => [],
        :dc_coverage_t      => [],
        :dc_date            => [],
        :dc_source          => [],
        :dc_subject         => [],
        :dc_type            => [],
        :dc_description     => [],
        :dc_creator         => [],
        :dc_language        => [],
        :dc_relation        => []
    )
  end

  def prepare_params
      array_fields = dc_fields + [:other_collections]
      array_fields.each do |f|
        params[:item][f].reject! { |v| v == '' } if params[:item][f]
      end
  end

  def sort_column
    Item.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end

