USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear y Modificar configuracion .logo-w
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
create proc [App].[spIUConfiguracionLogoW](
	@padding_bottom varchar(5)
    ,@padding_left	  varchar(5)
    ,@padding_right  varchar(5)
    ,@padding_top	  varchar(5)
) as
    declare @xml_logo XML = null
		  ,@JSON_logo nvarchar(max);

    select @xml_logo = (
	   select 
		   @padding_top as [padding_top]
		  ,@padding_right as [padding_right]
		  ,@padding_bottom as [padding_bottom]
		  ,@padding_left as [padding_left]
	   FOR XML path, root);

    select @JSON_logo = App.fsXMLToJSON(@xml_logo)

    if not exists (select top 1 1
	   from [App].[tblconfiguracionesGenerales]
	   where IDConfiguracion = '.logo-w')
    BEGIN
	   insert into [App].[tblconfiguracionesGenerales](IDConfiguracion,Valor,TipoValor,Descripcion)
	   select '.logo-w',@JSON_logo,'json_object','Objeto json que modifica la clase CSS .logo-w en el Login';		
    END ELSE
    BEGIN
	   update [App].[tblconfiguracionesGenerales]
		  set 
			 Valor  = @JSON_logo
	   where IDConfiguracion = '.logo-w'
    end;
GO
