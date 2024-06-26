USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]          
(      
   @IDPeriodo int             
  ,@DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacionMap] READONLY            
)          
AS          
BEGIN         

	declare  @msg varchar(max)
 -- declare @DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacionMap]

	if exists(select top 1 1 
			from @DetallePeriodoCapturaImportacion 
			where ClaveEmpleado is not null
			group by ClaveEmpleado,Codigo having count(*) > 1)
	begin
		 raiserror('Existen colaboradores con conceptos duplicados en el archivos.',16,1)
		 return
	end;

	if exists(select top 1 1 
			from @DetallePeriodoCapturaImportacion dp
				join Nomina.tblCatConceptos c with (nolock) on dp.Codigo = c.Codigo
				join Nomina.tblCatTiposPrestamo ctp with (nolock) on ctp.IDConcepto = c.IDConcepto
			where dp.ClaveEmpleado is not null
			)
	begin
		
		select top 1 @msg='No pueda importar capturas a conceptos que están asociados Tipos de Préstamos. ('+c.Codigo+' - '+c.Descripcion+')'
		from @DetallePeriodoCapturaImportacion dp
			join Nomina.tblCatConceptos c with (nolock) on dp.Codigo = c.Codigo
			join Nomina.tblCatTiposPrestamo ctp with (nolock) on ctp.IDConcepto = c.IDConcepto
		where dp.ClaveEmpleado is not null
			
		 raiserror(@msg,16,1)
		 return
	end;

	select           
		isnull(M.IDEmpleado,0) as IDEmpleado            
		,E.[ClaveEmpleado]      
		,isnull(M.NOMBRECOMPLETO,'') as NombreCompleto      
		,isnull(c.IDConcepto,0) as IDConcepto          
		,e.Codigo as Codigo      
		,isnull(c.Descripcion,'') as Descripcion      
		,isnull(e.CantidadMonto,0.00) as  CantidadMonto   
		,isnull(e.CantidadDias,0.00) as CantidadDias     
		,isnull(e.CantidadVeces,0.00) as CantidadVeces     
		,isnull(e.CantidadOtro1,0.00) as CantidadOtro1     
		,isnull(e.CantidadOtro2,0.00) as CantidadOtro2   
		,isnull(e.ImporteGravado,0.00) as ImporteGravado     
		,isnull(e.ImporteExcento,0.00) as ImporteExcento     
		,isnull(e.ImporteOtro,0.00) as ImporteOtro     
		,isnull(e.ImporteTotal1,0.00) as ImporteTotal1     
		,isnull(e.ImporteTotal2,0.00) as ImporteTotal2 
		
		
	from @DetallePeriodoCapturaImportacion E          
		left join RH.tblEmpleadosMaster m with (nolock)      
			on e.ClaveEmpleado = m.ClaveEmpleado      
		left join Nomina.tblCatConceptos c with (nolock)      
			on c.Codigo = e.Codigo     
		/*inner join Nomina.tblCatPeriodos p with (nolock)     
			on p.IDTipoNomina = m.IDTipoNomina    
				and p.IDPeriodo = @IDPeriodo*/  
	WHERE isnull(E.ClaveEmpleado,'') <>''          
END
GO
