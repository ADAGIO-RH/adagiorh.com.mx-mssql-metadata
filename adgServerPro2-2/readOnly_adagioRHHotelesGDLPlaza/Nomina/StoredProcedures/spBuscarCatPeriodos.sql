USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar periodos según los valores de los parámetros que recibe
** Autor			: Jose Rafael Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-23			Aneudy Abreu	Se agregó el parámetro @Ejercicio 
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spBuscarCatPeriodos]
(
	@IDPeriodo int = null
	,@IDTipoNomina int = null
	,@Ejercicio int = 0
)
AS
BEGIN
	SELECT p.IDPeriodo
		  , isnull(p.IDTipoNomina,0) as IDTipoNomina
		  ,tn.Descripcion as TipoNomina
		  , isnull(tn.IDPeriodicidadPago,0) as IDPeriodicidadPago
		  ,UPPER(pp.Descripcion) as PerioricidadPago
		  , ISNULL(tn.IDCliente,0) as IDCliente
		  , C.NombreComercial as Cliente
		  ,isnull(p.Ejercicio,0) as Ejercicio
		  ,UPPER(p.ClavePeriodo) AS ClavePeriodo
		  ,UPPER(p.Descripcion) AS Descripcion
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
		  ,isnull(p.Cerrado,0) as Cerrado
		  ,coalesce(UPPER(p.ClavePeriodo),'')+' '+coalesce(UPPER(substring(m.Descripcion,1,3)),'')+' '+coalesce(UPPER(p.Descripcion),'') as FullDescripcion
		  ,coalesce(UPPER(c.NombreComercial),'')+' ['+coalesce(UPPER(tn.Descripcion),'')+']' as ClienteTipoNomina
		  ,ROWNUMBER = ROW_NUMBER()Over(ORDER BY p.IDPeriodo)
	FROM Nomina.tblCatPeriodos p with (nolock)
		inner join Nomina.tblCatTipoNomina tn with (nolock)
			on p.IDTipoNomina = tn.IDTipoNomina
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock)
			on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		inner join Nomina.tblCatMeses m with (nolock)
			on p.IDMes = m.IDMes
		inner join RH.tblCatClientes c with (nolock)
			on tn.IDCliente = c.IDCliente
	where (p.IDPeriodo = @IDPeriodo or isnull(@IDPeriodo,0) = 0)
		and (tn.IDTipoNomina = @IDTipoNomina or isnull(@IDTipoNomina,0) = 0)
		and (p.Ejercicio = @Ejercicio or isnull(@Ejercicio,0) = 0)
		-- and p.Cerrado = 0
	order by p.Ejercicio desc, p.ClavePeriodo asc	
END
GO
