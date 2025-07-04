USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spIUArticulos](
	@IDArticulo int = null
	,@IDTipoArticulo int
	,@IDMetodoDepreciacion int = null
	,@IDUsuario int
	,@Nombre varchar(100)
	,@Descripcion varchar(500) = null
	,@UsoCompartido bit = null
	,@IDCatEstatusArticulo int 
	,@dtDetalleArticulos [ControlEquipos].[dtDetalleArticulos] readonly
)
as	
begin
	begin try
		BEGIN TRAN
		declare @IDIdioma varchar(20), @Cantidad int,@Error varchar(max)
		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');	
	
		if not exists(select top 1 1 from ControlEquipos.tblArticulos where IDArticulo = @IDArticulo)
		begin
				set @Cantidad = (select count(*) from @dtDetalleArticulos)
				-- Recuerda siempre poner un return despues de un raiserror!!
				--if exists(select top 1 1 from @dtDetalleArticulos where Costo is null or Costo = 0)
				--begin
				--	set @Error = 'Debes de ingresar el costo del artículo/s'
				--	raiserror(@Error, 16,1)
				--end
				
				if object_id('tempdb..#tempMergeDetalleA') is not null drop table #tempMergeDetalleA;          
                       	    
				insert into ControlEquipos.tblArticulos(IDTipoArticulo, IDMetodoDepreciacion, Nombre, Descripcion, FechaAlta, UsoCompartido,Cantidad)
				values(@IDTipoArticulo, @IDMetodoDepreciacion, UPPER(@Nombre), UPPER(@Descripcion), GETDATE(), @UsoCompartido,@Cantidad)

				set @IDArticulo = @@IDENTITY				
                
				;with cteTemp(IDDetalleArticulo,IDArticulo,IDGenero,Costo,JsonPropiedades,IDUnidadDeTiempo,IDCatTipoCaducidad,Tiempo,rn) AS  
				(  
					select	null,
							@IDArticulo,
							IDGenero,
							Costo,
							JsonPropiedades,
							case when IDUnidadDeTiempo = 0
								then
									null
								else 
									IDUnidadDeTiempo
							end,
							case when IDCatTipoCaducidad = 0
								then
									null
								else 
									IDCatTipoCaducidad
							end,
							Tiempo,
							ROW_NUMBER() OVER (ORDER BY (select null)) AS row_number 
					from @dtDetalleArticulos		
				)  
				select  
					IDDetalleArticulo, 
					cteTemp.IDArticulo,
					cteTemp.IDGenero,
					cteTemp.Costo,
					JsonPropiedades,
					cteTemp.IDUnidadDeTiempo, 
					cteTemp.IDCatTipoCaducidad,
					cteTemp.Tiempo,
					ControlEquipos.fnGetCodigoTrazable(a.IDTipoArticulo,rn-1) as Etiqueta
				into #tempMergeDetalleA    
				FROM cteTemp 
					inner join ControlEquipos.tblArticulos a on a.IDArticulo=@IDArticulo
					
				declare @MergeOutput as table (
					ActionTaken NVARCHAR(10),
					IDDetalleArticulo int,
					IDArticulo INT,
					IDGenero char(1),
					Costo decimal(10, 2),
					IDUnidadDeTiempo int,
					IDCatTipoCaducidad int,
					Tiempo int,
					JsonPropiedades nvarchar(max)
				);
				
				Merge ControlEquipos.tblDetalleArticulos AS Target 
					Using #tempMergeDetalleA AS Source on	
						Target.IDArticulo = Source.IDArticulo and Target.IDDetalleArticulo = Source.IDDetalleArticulo					
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (IDArticulo, Etiqueta,FechaAlta, IDGenero, Costo, IDUnidadDeTiempo, IDCatTipoCaducidad, Tiempo)
						VALUES(@IDArticulo,Source.Etiqueta, GETDATE(), source.IDGenero, source.Costo, source.IDUnidadDeTiempo, source.IDCatTipoCaducidad, source.Tiempo)					
					OUTPUT $action,
							inserted.IDDetalleArticulo,
							inserted.IDArticulo ,
							inserted.IDGenero,
							inserted.Costo,
							inserted.IDUnidadDeTiempo,
							inserted.IDCatTipoCaducidad,
							inserted.Tiempo,
							Source.JsonPropiedades
						into @MergeOutput;
										
					
				declare @i  int;										
				select @i = min(IDDetalleArticulo) from @MergeOutput
				declare @IDsDetallesArticulos varchar(max)            
				select @IDsDetallesArticulos = STRING_AGG(IDDetalleArticulo, ',') from @MergeOutput

				WHILE exists(select top 1 1 from @MergeOutput where IDDetalleArticulo >= @i)
				BEGIN								
					declare @dtPropiedades as table(
						IDValorPropiedad int, 
						IDPropiedad int , 
						Valor varchar(max),
						IDDetalleArticulo int 							
					);
					declare @jsonPropiedaes nvarchar(max)
					select @jsonPropiedaes = JsonPropiedades from @MergeOutput where IDDetalleArticulo=@i
										
					insert into @dtPropiedades (IDValorPropiedad,IDPropiedad,Valor,IDDetalleArticulo)
					select 
						IDValorPropiedad, 
						IDPropiedad, 
						Valor, 
						@i
					from OPENJSON(@jsonPropiedaes)
						WITH  (
							IDValorPropiedad int N'$.IDValorPropiedad',
							IDPropiedad int N'$.IDPropiedad',
							Valor varchar(max) N'$.Valor',
							IDDetalleArticulo int N'$.IDDetalleArticulo'			
						) info
											
					Merge ControlEquipos.tblValoresPropiedades as Target
						Using @dtPropiedades AS Source on	
							Target.IDDetalleArticulo = Source.IDDetalleArticulo and Target.IDPropiedad = Source.IDPropiedad			
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (IDPropiedad, Valor,IDDetalleArticulo)
						VALUES (Source.IDPropiedad,Source.Valor , Source.IDDetalleArticulo);
					 		

					delete from @dtPropiedades

					EXEC [ControlEquipos].[spIUEstatusArticulos]
					@IDUsuario = @IDUsuario,
					@IDCatEstatusArticulo = @IDCatEstatusArticulo,
					@IDEstatusArticulo = 0,
					@IDDetalleArticulo = @i,	
					@IDsEmpleados = '[]'
					select @i = min(IDDetalleArticulo) from @MergeOutput where IDDetalleArticulo > @i
				END;
				exec ControlEquipos.spIHistorialInventario
					@IDArticulo = @IDArticulo
					,@IDUsuario = @IDUsuario
					,@Cantidad = @Cantidad
					,@TipoMovimiento = 'IN'
					,@Razon = 'Alta inicial'
					,@IDsDetalleArticulo = @IDsDetallesArticulos
		end else
		begin
			update ControlEquipos.tblArticulos
			set
				Nombre          = UPPER(@Nombre)
				,Descripcion    = UPPER(@Descripcion)
				,IDMetodoDepreciacion = @IDMetodoDepreciacion
				,UsoCompartido	= @UsoCompartido
			where IDArticulo = @IDArticulo			
		end	

		exec [ControlEquipos].[spBuscarArticulos]
		@IDArticulo = @IDArticulo
		, @IDUsuario = @IDUsuario

		COMMIT TRAN
	end try
	begin catch
		ROLLBACK TRAN
		set @error = 'Ha ocurrido un error al intentar crear el artículo o actualizarlo'
		raiserror(@error, 16,1);
	end catch
end
GO
