USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************     
** Descripción  : BUSCAR los PTU's     
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-30    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/   

CREATE PROCEDURE [Nomina].[spBuscarPTU] (
	@IDPTU int = 0
)
AS
BEGIN
	
	SELECT PTU.IDPTU
		,PTU.IDEmpresa
		,emp.NombreComercial
		,emp.RFC
		,PTU.Ejercicio
		,PTU.ConceptosIntegranSueldo
		,PTU.DiasMinimosTrabajados
		,PTU.DiasDescontar
		,PTU.DescontarIncapacidades
		,PTU.TiposIncapacidadesADescontar
		,PTU.CantidadGanancia 
		,PTU.CantidadRepartir 
		,PTU.CantidadPendiente 
		,PTU.EjercicioPago
		,ISNULL(PTU.IDPeriodo, 0) as IDPeriodo
		,ISNULL(p.Descripcion,'[SIN PERIODO SELECCIONADO]') as Periodo
		,ISNULL(PTU.MontoSueldo, 0) as MontoSueldo
		,ISNULL(PTU.MontoDias, 0) as MontoDias
		,ISNULL(PTU.FactorSueldo, 0) as FactorSueldo
		,ISNULL(PTU.FactorDias, 0) as FactorDias
		,ISNULL(PTU.IDEmpleadoTipoSalarioMensualConfianza, 0) as IDEmpleadoTipoSalarioMensualConfianza
		,ISNULL(coalesce(e.ClaveEmpleado,'')+'-'+coalesce(e.NombreCompleto,''), '[NO SE A DETERMINADO EL TOPE]') as ColaboradorTopeMaximoConfianza
		,ISNULL(PTU.TopeSalarioMensualConfianza, 0) as TopeSalarioMensualConfianza 
		,ISNULL(PTU.TopeConfianza, 0) as TopeConfianza
		,ROW_NUMBER()over(Order by PTU.IDPTU ASC) as ROWNUMBER
	from Nomina.tblPTU PTU with (nolock)
		inner join RH.tblEmpresa Emp with (nolock) on PTU.IDEmpresa = Emp.IdEmpresa
		left join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = PTU.IDPeriodo
		left join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = PTU.IDEmpleadoTipoSalarioMensualConfianza
	Where (PTU.IDPTU = @IDPTU)  OR (@IDPTU = 0)
	ORDER BY PTU.Ejercicio desc, Emp.NombreComercial asc
END
GO
