USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [IMSS].[spBuscarClasificacionesIncapacidad](
    @IDClasificacionIncapacidad int = 0
    ,@IDTipoLesion int = 0
) as

 -- 1,5,8
    if (@IDTipoLesion = 0)
    begin
	   select IDClasificacionIncapacidad
		  ,Codigo
		  ,Nombre
	   from [Imss].[tblCatClasificacionesIncapacidad]
	   where (IDClasificacionIncapacidad = @IDClasificacionIncapacidad) or (@IDClasificacionIncapacidad = 0)

	   return;
    end

    if (@IDTipoLesion in (2,3,6,7,9))
    BEGIN
	   select IDClasificacionIncapacidad
		  ,Codigo
		  ,Nombre
	   from [Imss].[tblCatClasificacionesIncapacidad]
	   where (IDClasificacionIncapacidad = 5) 

	   return;
    END

    if (@IDTipoLesion in (4))
    BEGIN
	   select IDClasificacionIncapacidad
		  ,Codigo
		  ,Nombre
	   from [Imss].[tblCatClasificacionesIncapacidad]
	   where (IDClasificacionIncapacidad = 6) 

	   return;
    END

    if (@IDTipoLesion in (1,5,8))
    BEGIN
	   select IDClasificacionIncapacidad
		  ,Codigo
		  ,Nombre
	   from [Imss].[tblCatClasificacionesIncapacidad]
	   where IDClasificacionIncapacidad <= 4

	   return;
    END

	select IDClasificacionIncapacidad
		  ,Codigo
		  ,Nombre
	   from [Imss].[tblCatClasificacionesIncapacidad]
	   where IDClasificacionIncapacidad < 0
GO
