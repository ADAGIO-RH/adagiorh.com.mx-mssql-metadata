USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************           
** Descripción  : Procedimiento para Buscar los finiquitos por periodo          
** Autor   : Jose Roman          
** Email   : jose.roman@adagio.com.mx          
** FechaCreacion : 14-08-2018          
** Paremetros  :                        
****************************************************************************************************          
HISTORIAL DE CAMBIOS          
Fecha(yyyy-mm-dd)	Autor				Comentario          
------------------- ------------------- ------------------------------------------------------------          
2019-05-10			Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de       
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios        
***************************************************************************************************/          
CREATE PROCEDURE [Nomina].[spBuscarFiniquitosEmpleadoPeriodo](           
	@IDEmpleado int = 0,          
	@IDPeriodo int = 0,      
	@IDUsuario int      
)          
AS          
BEGIN          
	select           
		CF.IDFiniquito,          
		ISNULL(CF.IDPeriodo,0) as IDPeriodo,          
		P.ClavePeriodo,          
		P.Descripcion as Periodo,          
		ISNULL(CF.IDEmpleado,0) as IDEmpleado,          
		E.ClaveEmpleado,          
		e.NOMBRECOMPLETO,          
		ISNULL(CF.FechaBaja,getdate())FechaBaja,          
		ISNULL(CF.FechaAntiguedad,getdate())FechaAntiguedad,          
		CF.DiasVacaciones,          
		CF.DiasAguinaldo,          
		CF.DiasIndemnizacion90Dias,          
		CF.DiasIndemnizacion20Dias,          
		ISNULL(CF.IDEStatusFiniquito,0) as IDEstatusFiniquito,          
		EF.Descripcion as EstatusFiniquito,    
		isnull(DiasDePago,0.0) as DiasDePago,        
		isnull(DiasPorPrimaAntiguedad,0.0) as DiasPorPrimaAntiguedad,     
		isnull(SueldoFiniquito,0) as SueldoFiniquito,   
		cast(case when ISNULL(CF.IDEStatusFiniquito,0) in(0,1) then 0 else 1 end as bit) as Aplicado,
		isnull(c.Codigo,'000') +' - '+ isnull(c.Descripcion,'SIN CONCEPTO')  as ConceptoPago,
		isnull(dp.ImporteTotal1,0.00) as ImporteTotal1,
        ISNULL(CF.IDMovAfiliatorio,0) as IDMovAfiliatorio
	from Nomina.tblControlFiniquitos CF          
		Inner join Nomina.tblCatPeriodos P on P.IDPeriodo = CF.IDPeriodo          
		Inner Join RH.tblEmpleadosMaster E on CF.IDEmpleado = E.IDEmpleado          
		Inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario      
		Inner join Nomina.tblCatEstatusFiniquito EF on EF.IDEStatusFiniquito = CF.IDEStatusFiniquito 
		left join Nomina.tblDetallePeriodoFiniquito dp on dp.IDConcepto in(select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5) and dp.IDEmpleado = cf.IDEmpleado and dp.IDPeriodo = cf.IDPeriodo and isnull(dp.ImporteTotal1,0) > 0 
		left join Nomina.tblcatConceptos c on dp.IDConcepto = c.IDConcepto         
	WHERE (CF.IDEmpleado = @IDEmpleado) AND (CF.IDPeriodo = @IDPeriodo)           
            
          
END
GO
