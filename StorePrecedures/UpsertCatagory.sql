--UpsertCatagory 'test_UpsertCatagory','大 家 电',3,0

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
	@nextid smallint=null,
	@nextnavid smallint=null
	
	-- new add by wgy -------------------------------
	,@pid smallint=null
	-------------------------------------------------
	
                                                                                                                                                                                                                                             
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SET IDENTITY_INSERT 'bsp_categories' ON;

   select @cateid=cateid from bsp_categories where LTRIM(RTRIM(name))=@name;
   if(@cateid is null)
	   begin
		select @nextid =IDENT_CURRENT('bsp_categories')+1;
		select @parentid=cateid from bsp_categories where LTRIM(RTRIM(name))=@parentName;
		
		--INSERT INTO bsp_categories(name,displayorder,parentid,layer,haschild,path) Values(@name,0,@parentid,@layer,@haschild,@parentid+','+@nextid);
		INSERT INTO bsp_categories(name,displayorder,parentid,layer,haschild,[path]) Values(@name,0,@parentid,@layer,@haschild,cast(@parentid as varchar(10))+','+cast(@nextid as varchar(10)));
		
		
		-- new add 插入 navs 表数据 ------------------------------------
		--这里假设nav和categories 名称一致,或者用url里包含的cateid来查找？
		select @pid=[id] from bsp_navs where LTRIM(RTRIM(name))=@parentName;
		--select @pid=@parentid  from bsp_navs where  url = '/list/'+@cateid+'.html'
		
		if(@pid is not null)
   			begin
				INSERT INTO bsp_navs([pid],[layer],[name],[title],[url],[target],[displayorder]) Values(@pid,@layer,@name,'title','/list/'+cast(@nextid as varchar(10))+'.html',0,0);
				--INSERT INTO bsp_navs([pid],[layer],[name],[title],[url],[target],[displayorder]) Values(@pid,@layer,@name,'title','/list/'+'.html',0,0);
			end
		else
			begin
				--在没有找到navs表父节点的情况下如何插入？
				select @nextnavid =IDENT_CURRENT('bsp_navs');
				--INSERT INTO bsp_navs([pid],[layer],[name],[title],[url],[target],[displayorder]) Values(0,1,@name,'title','/list/'+cast(@cateid as varchar(10))+'.html',0,0);
			
			end
		----------------------------------------------------------------
			
		end
   else
	begin
		select @parentid=cateid from bsp_categories where LTRIM(RTRIM(name))=@parentName;
		UPDATE bsp_categories SET
		parentid=coalesce(@parentid, parentid),
		layer=coalesce(@layer,layer),
		haschild=coalesce(@haschild,haschild)
		,path=coalesce(@parentid+@nextid,path)
		WHERE name=@name;
		
		
		-- new add 更新 navs 表数据 ------------------------------------
		--这里假设nav和categories 名称一致,或者用url里包含的cateid来查找？
		select @pid=@parentid from bsp_navs where LTRIM(RTRIM(name))=@name;
		if(@pid is not null)
   			begin
				UPDATE bsp_navs
				   SET [pid] = @pid
					  ,[layer] = coalesce(@layer,layer)
					  ,[url] = '/list/'+@cateid+'.html'
				WHERE  LTRIM(RTRIM(name))=@name;
			end
		----------------------------------------------------------------
		
	end
END
GO
