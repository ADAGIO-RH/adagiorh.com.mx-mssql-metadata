USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para BORRAR los finiquitos 
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 11-04-2019  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  

CREATE PROCEDURE [Nomina].[spBorrarFiniquitos] --1  
(   
	@IDFiniquito int = 0,  
	@IDPeriodo int = 0,
	@IDUsuario int   
)  
as
BEGIN
	declare 
		@IDEmpleado int,
		@EstatusFiniquito varchar(max),
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarFiniquitos]',
		@Tabla		varchar(max) = '[Nomina].[tblControlFiniquitos]',
		@Accion		varchar(20)	= 'DELETE'
	;

	select @OldJSON = a.JSON 
	from (
		Select       
			CF.IDFiniquito,      
			ISNULL(CF.IDPeriodo,0) as IDPeriodo,      
			P.ClavePeriodo,      
			P.Descripcion as Periodo,      
			ISNULL(CF.IDEmpleado,0) as IDEmpleado,      
			E.ClaveEmpleado,      
			e.NOMBRECOMPLETO as Colaborador,      
			ISNULL(CF.FechaBaja,getdate())FechaBaja,      
			ISNULL(CF.FechaAntiguedad,getdate())FechaAntiguedad,      
			CF.DiasVacaciones,      
			CF.DiasAguinaldo,      
			CF.DiasIndemnizacion90Dias,      
			CF.DiasIndemnizacion20Dias,      
			ISNULL(CF.IDEStatusFiniquito,0) as IDEstatusFiniquito,      
			EF.Descripcion as EstatusFiniquito,
			isnull(DiasDePago,0) as DiasDePago,				
			isnull(DiasPorPrimaAntiguedad,0) as DiasPorPrimaAntiguedad,	
			isnull(SueldoFiniquito,0) as SueldoFiniquito,
			cast(case when ISNULL(CF.IDEStatusFiniquito,0) in(0,1) then 0 else 1 end as bit) as Aplicado,
			isnull(c.Codigo,'000') +' - '+ isnull(c.Descripcion,'SIN CONCEPTO')  as ConceptoPago,
			isnull(dp.ImporteTotal1,0.00) as ImporteTotal1
		from Nomina.tblControlFiniquitos CF with (nolock)     
			Inner join Nomina.tblCatPeriodos P with (nolock) on P.IDPeriodo = CF.IDPeriodo      
			Inner Join RH.tblEmpleadosMaster E with (nolock) on CF.IDEmpleado = E.IDEmpleado      
			Inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario  
			Inner join Nomina.tblCatEstatusFiniquito EF with (nolock) on EF.IDEStatusFiniquito = CF.IDEStatusFiniquito 
			left join Nomina.tblDetallePeriodoFiniquito dp with (nolock) on dp.IDConcepto in(select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5) and dp.IDEmpleado = cf.IDEmpleado and dp.IDPeriodo = cf.IDPeriodo and dp.ImporteTotal1 is not null
			left join Nomina.tblcatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
		WHERE (CF.IDFiniquito = @IDFiniquito) OR (CF.IDPeriodo = @IDPeriodo) 
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	

	select TOP 1 
		@IDEmpleado = IDEmpleado
		, @EstatusFiniquito = ef.Descripcion
	from Nomina.tblControlFiniquitos cf with (nolock)
		inner join Nomina.tblCatEstatusFiniquito ef with (nolock)
			on ef.IDEStatusFiniquito = cf.IDEStatusFiniquito
	where IDFiniquito = @IDFiniquito and IDPeriodo = @IDPeriodo

	Delete Nomina.tblDetallePeriodoFiniquito
	where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo

	--if(@EstatusFiniquito = 'Aplicar')
	--BEGIN
	--END

	Delete Nomina.tblDetallePeriodo
	where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo

	delete Nomina.tblControlFiniquitos
	where IDFiniquito = @IDFiniquito and IDPeriodo = @IDPeriodo

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
