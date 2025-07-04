USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear y Modificar configuraciones de la aplicación
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-12
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create proc [App].[spIUConfiguracion](
	@IDConfiguracion	varchar	(255)
    ,@Valor			nvarchar	(max)
    ,@TipoValor		varchar	(20)
    ,@Descripcion		varchar	(500)
) as
    if not exists (select top 1 1
	   from [App].[tblconfiguracionesGenerales]
	   where IDConfiguracion = @IDConfiguracion)
    BEGIN
	   insert into [App].[tblconfiguracionesGenerales](IDConfiguracion,Valor,TipoValor,Descripcion)
	   select @IDConfiguracion,@Valor,@TipoValor,@Descripcion		
    END ELSE
    BEGIN
	   update [App].[tblconfiguracionesGenerales]
		  set 
			  IDConfiguracion  = @IDConfiguracion
			 ,Valor		    = @Valor
			 ,TipoValor	    = @TipoValor
			 ,Descripcion	    = @Descripcion
	   where IDConfiguracion = @IDConfiguracion
    end;
GO
