USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCatTipoNomina](        
	@IDCliente int = null        
	,@IDUsuario int = null   
	,@IDTipoNomina int = null     
)        
AS        
BEGIN      
	SET FMTONLY OFF;     
    
	DECLARE @IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


	IF OBJECT_ID('tempdb..#TempTiposNomina') IS NOT NULL DROP TABLE #TempTiposNomina    
    
	select ID     
	Into #TempTiposNomina    
	from Seguridad.tblFiltrosUsuarios     
	where IDUsuario = @IDUsuario and Filtro = 'TiposNomina'    
 
	Select         
		tp.IDTipoNomina,        
		tp.Descripcion,        
		tp.IDPeriodicidadPago,        
		upper(pp.Descripcion) as PerioricidadPago,        
		isnull(tp.IDPeriodo,0) as IDPeriodo,        
		p.ClavePeriodo,      
		upper(p.Descripcion) as DescripcionPeriodo,        
		ISNULL(C.IDCliente,0) as IDCliente,        
		JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
		ISNULL(Pais.IDPais,0) as IDPais,
		Pais.Descripcion as Pais
	from Nomina.tblCatTipoNomina tp   with (nolock)     
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock) on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago 
			and ((tp.IDTipoNomina = @IDTipoNomina)  OR(ISNULL(@IDTipoNomina,0) = 0))
		left join Nomina.tblCatPeriodos p  with (nolock) on tp.IDPeriodo = p.IDPeriodo        
		Inner Join RH.tblCatClientes c   with (nolock) on tp.IDCliente = c.IDCliente
		left join SAT.tblCatPaises Pais with (nolock) on Pais.IDPais = tp.IDPais
	where (tp.IDCliente = @IDCliente) or (ISNULL(@IDCliente,0) = 0)      
		and (tp.IDTipoNomina in  ( select ID from #TempTiposNomina)    
			OR Not Exists(select ID from #TempTiposNomina)) 
	ORDER BY c.NombreComercial, tp.Descripcion ASC        
END
GO
