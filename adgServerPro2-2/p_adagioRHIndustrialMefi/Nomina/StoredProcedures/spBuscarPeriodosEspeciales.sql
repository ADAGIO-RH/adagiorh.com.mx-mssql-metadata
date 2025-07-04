USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Buscar periodos especiales
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-04-23
** Paremetros		:              

	@Tipo : -1 = Todos
			0 = Solo periodos abiertos
			1 = Solo periodos cerrados

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

[Nomina].[spBuscarPeriodosEspeciales] 2020, 1
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spBuscarPeriodosEspeciales] (
	@Ejercicio int = 0,
	@Tipo int = -1
)
AS
BEGIN

   DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')


	SELECT 
		p.IDPeriodo
		,isnull(p.IDTipoNomina,0) as IDTipoNomina
		,tn.Descripcion as TipoNomina
		,isnull(tn.IDPeriodicidadPago,0) as IDPeriodicidadPago
		,upper(pp.Descripcion) as PerioricidadPago
		,isnull(tn.IDCliente,0) as IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,isnull(p.Ejercicio,0) as Ejercicio
		,upper(p.ClavePeriodo) AS ClavePeriodo
		,upper(p.Descripcion) AS Descripcion
		,p.FechaInicioPago
		,p.FechaFinPago
		,p.FechaInicioIncidencia
		,p.FechaFinIncidencia
		,isnull(p.Dias,0) as Dias
		,isnull(p.AnioInicio,0) as AnioInicio
		,isnull(p.AnioFin,0) as AnioFin
		,isnull(p.MesInicio,0) as MesInicio
		,isnull(p.MesFin,0) as MesFin
		,p.IDMes
		,m.Descripcion Mes
		,isnull(p.BimestreInicio,0) as BimestreInicio
		,isnull(p.BimestreFin,0) as BimestreFin
		,isnull(p.General,0) as General
		,isnull(p.Finiquito,0) as Finiquito
		,isnull(p.Especial,0) as Especial
		,isnull(p.Aguinaldo,0) as Aguinaldo
		,isnull(p.PTU,0) as PTU
		,isnull(p.DevolucionFondoAhorro,0) as DevolucionFondoAhorro
		,isnull(p.Presupuesto,0) as Presupuesto
		,isnull(p.Cerrado,0) as Cerrado
		,coalesce(upper(p.ClavePeriodo),'')+' '+coalesce(upper(substring(m.Descripcion,1,3)),'')+' '+coalesce(upper(p.Descripcion),'') as FullDescripcion
		,coalesce(upper(c.NombreComercial),'')+' ['+coalesce(upper(tn.Descripcion),'')+']' as ClienteTipoNomina
		,ROWNUMBER = ROW_NUMBER()Over(ORDER BY p.IDPeriodo)
	FROM Nomina.tblCatPeriodos p with (nolock)
		inner join Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		inner join Nomina.tblCatMeses m with (nolock) on p.IDMes = m.IDMes
		inner join RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente
	where ISNULL(p.Especial, 0) = 1
		and (p.Ejercicio = @Ejercicio or isnull(@Ejercicio,0) = 0) 
		and (ISNULL(p.Cerrado, 0) = case when @Tipo = -1 then ISNULL(p.Cerrado, 0) else @Tipo end)
	order by p.Ejercicio desc, p.ClavePeriodo asc	
END
GO
