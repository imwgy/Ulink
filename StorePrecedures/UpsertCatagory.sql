IF OBJECT_ID ( 'UpsertCatagory', 'P' ) IS NOT NULL 
    DROP PROCEDURE UpsertCatagory;
GO
CREATE PROCEDURE UpsertCatagory

@name nchar(120)=null,
@parentName nchar(120)=null,
@layer tinyint=null,
@haschild tinyint=null
AS
BEGIN
	DECLARE 
	@cateid smallint=null,
	@parentid smallint=null,
	@nextid smallint=null

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET IDENTITY_INSERT 'bsp_categories' ON;

   select @cateid=cateid from bsp_categories where LTRIM(RTRIM(name))=@name;
   if(@cateid is null)
	   begin
		select @nextid =IDENT_CURRENT('bsp_categories');
		select @parentid=cateid from bsp_categories where LTRIM(RTRIM(name))=@parentName;
		INSERT INTO bsp_categories(cateid,name,parentid,layer,haschild,path) Values(@nextid,@name,@parentid,@layer,@haschild,@parentid+','+@nextid);
		end
   else
	begin
		select @parentid=cateid from bsp_categories where LTRIM(RTRIM(name))=@parentName;
		UPDATE bsp_categories SET
		parentid=coalesce(@parentid, parentid),
		layer=coalesce(@layer,layer),
		haschild=coalesce(@haschild,haschild),
		path=coalesce(@parentid+','+@nextid,path)
		WHERE name=@name;
	end
END
GO
