USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spValidarChecada_Custom](              
	@IDEmpleado int,    
	@dtEmpleados2 [RH].[dtEmpleados] readonly,          
	@FechaOrigen Date,                  
	@outChecadaValida bit output,              
	@outMensajeValidacion Varchar(MAX) output,
	@outEsRepetida bit output              
)              
AS              
BEGIN              
  
	SET DATEFORMAT ymd;            
              
	declare                  
		@ClaveEmpleado varchar(20),            
		@dtEmpleados [RH].[dtEmpleados],              
		@ChecadaValida bit = 1,              
		@MensajeValidacion Varchar(MAX),   
		@EsRepetida bit = 0
	;      
        
   
	insert @dtEmpleados
	select * from @dtEmpleados2      
        
	if not exists (select top 1 1 from @dtEmpleados)
	begin
		insert into @dtEmpleados    
		select * from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado       
	end
              
	select top 1 @ClaveEmpleado = ClaveEmpleado from @dtEmpleados where IDEmpleado = @IDEmpleado              

 --=========================================              
--=======CONTRATO==========================             
	if ((@ChecadaValida = 1) and (@EsRepetida = 0))	
	BEGIN        
		if ((select cast(valor as bit) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ValidarContratos') = 1)              
		BEGIN           
			if(isnull((select top 1 tc.Codigo 
						from @dtEmpleados e       
							left join sat.tblCatTiposContrato tc with(nolock)      
							on tc.IDTipoContrato = e.IDTipoContrato           
						where e.IDEmpleado = @IDEmpleado ),'') <> '01')              
			BEGIN           
				if exists (select top 1 1 from @dtEmpleados where IDEmpleado = @IDEmpleado and @FechaOrigen Between FechaIniContrato and FechaFinContrato)              
				BEGIN          
					set @ChecadaValida = 1;              
					set @MensajeValidacion ='';              
				END              
				ELSE              
				BEGIN           
					set @ChecadaValida = 0;              
					set @MensajeValidacion ='El Colaborador con clave: '+@ClaveEmpleado+' no tiene Contrato Vigente. Favor Pasar por Recursos Humanos.';              
				END       
			END ELSE              
			BEGIN        
				set @ChecadaValida = 1;              
				set @MensajeValidacion ='';              
			END              
		END             
		ELSE              
		BEGIN              
			set @ChecadaValida = 1;              
			set @MensajeValidacion ='';              
		END     
	END      
--=======CONTRATO==========================              
--=========================================              
            
	select  @outChecadaValida		= @ChecadaValida       
			,@outMensajeValidacion	= @MensajeValidacion
			,@outEsRepetida			= @EsRepetida      
              
RETURN              
              
END
GO
