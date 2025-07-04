USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los tipos de préstamos
** Autor			: Jose Rafael Roman
** Email			: jose.rafael@adagio.com.mx
** FechaCreacion	: 2017-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2021-03-09			Aneudy Abreu		Agregé el campo [Intranet], este campo permite habilitar un
										tipo de préstamo para que los colaboradores puedan solicitarlos
										a travéz de la Intranet.
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spBuscarTiposPrestamo](  
	@IDTipoPrestamo int = null,
	@SoloTiposConConcepto bit = 0,
	@SoloIntranet bit = 0,
    @IDUsuario int =null
)  
AS  
BEGIN  
Declare @IDIdioma as VARCHAR(max)
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		p.IDTipoPrestamo  
		,p.Codigo  
		--,p.Descripcion  
        ,UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion 
		,isnull(p.IDConcepto,0) as IDConcepto  
		,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto  
		,ISNULL(p.Intranet, 0) as Intranet
		,ROW_NUMBER()over(ORDER BY P.IDTipoPrestamo)as ROWNUMBER  
	FROM Nomina.tblCatTiposPrestamo p with (nolock)   
		left join Nomina.tblCatConceptos c with (nolock) on p.IDConcepto = c.IDConcepto  
	WHERE (IDTipoPrestamo = @IDTipoPrestamo) or (@IDTipoPrestamo is null) 
		and (isnull(p.IDConcepto,0) > 0 or @SoloTiposConConcepto = 0)
		and (isnull(p.Intranet,0) = 1 or @SoloIntranet = 0)
END
GO
