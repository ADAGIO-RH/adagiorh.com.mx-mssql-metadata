USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [ControlEquipos].[spIDetalleArticulos](
	@IDUsuario int
	,@IDCatEstatusArticulo int
	,@dtDetalleArticulos [ControlEquipos].[dtDetalleArticulos] readonly	
)
as	
begin    
	declare 
		@IDIdioma varchar(20)
		,@i  int										
		,@IDsDetallesArticulos varchar(max)
		,@IDArticulo int
		,@Cantidad int
	;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    if object_id('tempdb..#tempMergeDetalleA') is not null drop table #tempMergeDetalleA; 
	
    ;with cteTemp(IDDetalleArticulo,IDArticulo,IDGenero,Costo,JsonPropiedades,IDUnidadDeTiempo,IDCatTipoCaducidad,Tiempo,rn) AS  
    (  
		select null,
			   IDArticulo,
			   IDGenero,
			   Costo,
			   JsonPropiedades,
			   IDUnidadDeTiempo,
			   IDCatTipoCaducidad,
			   Tiempo
			   ,ROW_NUMBER() OVER (ORDER BY (select null)) AS rn 
        from @dtDetalleArticulos		
    ) 
	
    select 
		IDDetalleArticulo
		,cteTemp.IDArticulo
		,cteTemp.IDGenero
		,Costo
		,JsonPropiedades
		,IDUnidadDeTiempo
		,IDCatTipoCaducidad
		,Tiempo
		,ControlEquipos.fnGetCodigoTrazable(a.IDTipoArticulo,rn-1)  as Etiqueta
    into #tempMergeDetalleA    
    FROM cteTemp 
		inner join ControlEquipos.tblArticulos a on a.IDArticulo=cteTemp.IDArticulo



    Merge ControlEquipos.tblDetalleArticulos AS Target 
    Using #tempMergeDetalleA AS Source on	
        Target.IDArticulo = Source.IDArticulo and Target.IDDetalleArticulo = Source.IDDetalleArticulo    
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (IDArticulo, Etiqueta, FechaAlta, IDGenero, Costo, IDUnidadDeTiempo, IDCatTipoCaducidad, Tiempo)
        VALUES(IDArticulo,Source.Etiqueta,GETDATE(), source.IDGenero, source.Costo, source.IDUnidadDeTiempo, source.IDCatTipoCaducidad, source.Tiempo)    
    OUTPUT 
        inserted.IDDetalleArticulo, 
        Source.IDArticulo,
		source.IDGenero,
		source.Costo,
        Source.JsonPropiedades,        
		Source.IDUnidadDeTiempo,
		Source.IDCatTipoCaducidad,
		Source.Tiempo,
		Source.Etiqueta
    into #tempMergeDetalleA;

    delete from #tempMergeDetalleA  where IDDetalleArticulo is null;    
    
    select @i = min(IDDetalleArticulo) from #tempMergeDetalleA
	select @IDArticulo = min(IDArticulo), @Cantidad = count(IDDetalleArticulo) from #tempMergeDetalleA
	select @IDsDetallesArticulos = STRING_AGG(IDDetalleArticulo, ',') from #tempMergeDetalleA

    WHILE exists(select top 1 1 from #tempMergeDetalleA where IDDetalleArticulo >= @i)
	BEGIN                        
        declare @dtPropiedades as table(
            IDValorPropiedad int, 
            IDPropiedad int , 
            Valor varchar(max),
            IDDetalleArticulo int                     
        );

        DECLARE @IDDetalleArticulo INT 
        set @IDDetalleArticulo=@i;
        declare @jsonPropiedaes nvarchar(max)
        select @jsonPropiedaes = JsonPropiedades from #tempMergeDetalleA where IDDetalleArticulo=@i
                        
        insert into @dtPropiedades (IDValorPropiedad,IDPropiedad,Valor,IDDetalleArticulo)
        select 
            IDValorPropiedad, 
            IDPropiedad, 
            Valor, 
            @i
        from OPENJSON(@jsonPropiedaes)
        WITH (
            IDValorPropiedad int N'$.IDValorPropiedad',
            IDPropiedad int N'$.IDPropiedad',
            Valor varchar(max) N'$.Valor'                    
        ) info        
            
        insert into ControlEquipos.tblValoresPropiedades (IDPropiedad,IDDetalleArticulo,Valor)
        select IDPropiedad,@IDDetalleArticulo,Valor
        from @dtPropiedades 
		
		EXEC [ControlEquipos].[spIUEstatusArticulos]
			@IDUsuario = @IDUsuario,
			@IDCatEstatusArticulo = @IDCatEstatusArticulo,
			@IDEstatusArticulo = 0,
			@IDDetalleArticulo = @i,	
			@IDsEmpleados = '[]'

        delete from @dtPropiedades
        select @i = min(IDDetalleArticulo) from #tempMergeDetalleA where IDDetalleArticulo > @i
    END;

	exec ControlEquipos.spIHistorialInventario
		@IDArticulo = @IDArticulo
		,@IDUsuario = @IDUsuario
		,@Cantidad = @Cantidad
		,@TipoMovimiento = 'IN'
		,@Razon = 'Nuevos articulos'
		,@IDsDetalleArticulo = @IDsDetallesArticulos

end
GO
