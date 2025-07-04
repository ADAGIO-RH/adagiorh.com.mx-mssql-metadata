USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spActualizarOrdenCatPropiedades](
	@IDPropiedad int	
	,@OldIndex int			
	,@NewIndex int			
	,@IDUsuario int	
)
as
begin
	declare 
		@i int = 1, @IDTipoArticulo int

	if OBJECT_ID('tempdb..#tblTempCatPropiedades')  is not null drop table #tblTempCatPropiedades;
    if OBJECT_ID('tempdb..#tblTempCatPropiedades1') is not null drop table #tblTempCatPropiedades1;
	select @IDTipoArticulo = IDTipoArticulo from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad

	if ((@NewIndex < @OldIndex) or (@OldIndex = 0))
    begin
		  select IDPropiedad, Traduccion, Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempCatPropiedades
		  from ControlEquipos.tblCatPropiedades
		  where Orden >= @NewIndex and IDPropiedad <> @IDPropiedad and IDTipoArticulo = @IDTipoArticulo;

		  update ControlEquipos.tblCatPropiedades
			 set Orden = @NewIndex
		  where IDPropiedad = @IDPropiedad

		  while exists(select 1 from #tblTempCatPropiedades where ID >= @i)
		  begin
			 select @IDPropiedad = IDPropiedad from #tblTempCatPropiedades where  ID = @i
			 set @NewIndex = @NewIndex+1

			 update ControlEquipos.tblCatPropiedades
				set Orden = @NewIndex
			 where IDPropiedad = @IDPropiedad
		  
			 select @i = @i + 1;
		  end;		
    end else
    begin
		  select IDPropiedad ,Traduccion, Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempCatPropiedades1
		  from ControlEquipos.tblCatPropiedades
		  where (Orden between @OldIndex and @NewIndex) and IDPropiedad <> @IDPropiedad  and IDTipoArticulo = @IDTipoArticulo;

		  update ControlEquipos.tblCatPropiedades
			 set Orden = @NewIndex
		  where IDPropiedad = @IDPropiedad

		  while exists(select 1 from #tblTempCatPropiedades1 where ID >= @i)
		  begin
			 select @IDPropiedad = IDPropiedad from #tblTempCatPropiedades1 where ID = @i

			 update ControlEquipos.tblCatPropiedades
				set Orden = @OldIndex
			 where IDPropiedad = @IDPropiedad

			 set @OldIndex = @OldIndex + 1

			 select @i = @i + 1;
		  end;
    end;
end
GO
