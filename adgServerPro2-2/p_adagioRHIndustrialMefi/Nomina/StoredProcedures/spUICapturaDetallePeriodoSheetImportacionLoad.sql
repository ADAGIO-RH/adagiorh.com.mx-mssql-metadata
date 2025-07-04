USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]          
(      
   @IDPeriodo int          
   ,@IDUsuario int   
  ,@DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacionMap] READONLY            
  ,@PermitirEmpleadosNoVigentes bit     
)          
AS          
BEGIN         

	DECLARE  @msg varchar(max)
    DECLARE @ClaveEmpleadoNoVigentes VARCHAR(max) 
    DECLARE @ClaveEmpleadoNoExistentes VARCHAR(max) 
    declare @DatoExtra varchar(10)
    
    select @DatoExtra= CASE @PermitirEmpleadosNoVigentes WHEN  1 THEN 'Vigentes' when 0 then 'No Vigentes' else 'Otro valor' end
 -- declare @DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacionMap]

	if exists(select top 1 1 
			from @DetallePeriodoCapturaImportacion 
			where ClaveEmpleado is not null
			group by ClaveEmpleado,Codigo having count(*) > 1)
	begin
		 raiserror('Existen colaboradores con conceptos duplicados en el archivos.',16,1)
		 return
	end;

    select  @ClaveEmpleadoNoVigentes=COALESCE(@ClaveEmpleadoNoVigentes+ ', ', '') + coalesce(d.ClaveEmpleado,'') from @DetallePeriodoCapturaImportacion as d
    left join RH.tblEmpleadosMaster m on m.ClaveEmpleado=d.ClaveEmpleado
    where m.ClaveEmpleado is not null and m.Vigente=0


   

    if(@PermitirEmpleadosNoVigentes = 0)
    begin
        if( @ClaveEmpleadoNoVigentes!='')
        begin 
            select @msg=concat('Los siguientes colaboradores (',@ClaveEmpleadoNoVigentes ,') se encuentran con estatus no vigente, Favor de quitarlos del archivo.')
            EXEC [Auditoria].[spIAuditoria]
			    @IDUsuario		= @IDUsuario
			    ,@Tabla			= ''
			    ,@Procedimiento	= '[Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]'
			    ,@Accion		= 'Map de importacion'
			    ,@NewData		= ''
			    ,@OldData		= ''
			    ,@Mensaje		=  @msg
			    ,@InformacionExtra		= @DatoExtra

            raiserror(@msg,16,1)
            return
        end;
    end
 
 
  

    select  @ClaveEmpleadoNoExistentes=COALESCE(@ClaveEmpleadoNoExistentes+ ', ', '') + coalesce(d.ClaveEmpleado,'') from @DetallePeriodoCapturaImportacion as d
    left join RH.tblEmpleadosMaster m on m.ClaveEmpleado=d.ClaveEmpleado
    where m.ClaveEmpleado is  null and d.ClaveEmpleado is not null
 
    if( @ClaveEmpleadoNoExistentes!='')
    begin 
        select @msg=concat('Las siguientes claves de colaboradores (',@ClaveEmpleadoNoExistentes ,') no se encontraron en el sistema, Favor de revisarlos de nuevo.')

         EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= ''
			,@Procedimiento	= '[Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]'
			,@Accion		= 'Map de importacion'
			,@NewData		= ''
			,@OldData		= ''
			,@Mensaje		=  @msg
			,@InformacionExtra		= @DatoExtra

        raiserror(@msg,16,1)
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
			
        EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= ''
			,@Procedimiento	= '[Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]'
			,@Accion		= 'Map de importacion'
			,@NewData		= ''
			,@OldData		= ''
			,@Mensaje		=  @msg
			,@InformacionExtra	= @DatoExtra

		 raiserror(@msg,16,1)
		 return
	end;


    
     EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= ''
			,@Procedimiento	= '[Nomina].[spUICapturaDetallePeriodoSheetImportacionLoad]'
			,@Accion		= 'Map de importacion'
			,@NewData		= ''
			,@OldData		= ''
			,@Mensaje		= 'Importacion con exito.'
			,@InformacionExtra		= @DatoExtra

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
