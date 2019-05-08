module Meta
  def with_meta(meta)
    raise 'Unimplemented'
  end

  def meta
    @meta
  end

  def vary_meta
    if block_given?
      with_meta(yield(meta))
    end
  end
end