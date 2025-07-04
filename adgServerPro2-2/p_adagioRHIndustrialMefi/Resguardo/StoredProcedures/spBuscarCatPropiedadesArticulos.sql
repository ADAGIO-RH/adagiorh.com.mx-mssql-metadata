USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Propiedades de Artículos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2020-24-03
** Paremetros		:    
	TipoReferencia:
		0 : Asignado a un tipo de Articulo
		1 : Asignado a un Artículo
		2 : Asignado a un Artículo - Propiedad Extra
     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0     
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Resguardo].[spBuscarCatPropiedadesArticulos](
	@IDPropiedad int = 0
	,@TipoReferencia int = 0
	,@IDReferencia int = 0
	,@IDUsuario int
) as
	declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
	;

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u with (nolock)
	   Inner join App.tblPreferencias p with (nolock) on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp  with (nolock) on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp  with (nolock) on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;
	
	select 
		 cta.IDPropiedad
		,cta.IDTipoPropiedad
		,ctp.Nombre as TipoPropiedad
		,cta.Nombre 
		,cta.TipoReferencia 
		,cta.IDReferencia
		,case when ctaOriginal.IDPropiedad is null then upper(cta.Varios) else upper(ctaOriginal.Varios) end as Varios
		,upper(cta.Valor) as Valor

	from [Resguardo].[tblCatPropiedadesArticulos] cta with (nolock)
		join [Resguardo].[tblCatTiposPropiedades] ctp with (nolock) on cta.IDTipoPropiedad = ctp.IDTipoPropiedad
		left join [Resguardo].[tblCatPropiedadesArticulos] ctaOriginal with (nolock) on cta.CopiadaDelIDPropiedad = ctaOriginal.IDPropiedad
	where (cta.IDPropiedad = @IDPropiedad) or ( 
			isnull(@IDPropiedad,0) = 0 and
		  (cta.TipoReferencia = @TipoReferencia /* or @TipoReferencia = 0 */) and 
		  (cta.IDReferencia = @IDReferencia /* or @IDReferencia = 0 */) )
GO
