USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblProgramasCapacitacionDC2](
	[IDProgramaCapacitacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[Email] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fax] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[QtyTrabajadoresConsiderados] [int] NULL,
	[Mujeres] [int] NULL,
	[Hombres] [int] NULL,
	[ObjetivoActualizar] [int] NULL,
	[ObjetivoPrevenir] [int] NULL,
	[ObjetivoIncrementar] [int] NULL,
	[ObjetivoMejorar] [int] NULL,
	[ObjetivoPreparar] [int] NULL,
	[ModalidadEspecificos] [bit] NULL,
	[ModalidadComunes] [bit] NULL,
	[ModalidadGeneral] [bit] NULL,
	[NumeroEstablecimientos] [int] NULL,
	[NumeroEtapas] [int] NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[RegPatronalesAdicionales] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteLegal] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaElaboracion] [date] NULL,
	[LugarElaboracion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_STPSTblProgramasCapacitacionDC2_IDProgramaCapacitacion] PRIMARY KEY CLUSTERED 
(
	[IDProgramaCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblProgramasCapacitacionDC2]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_STPSTblProgramasCapacitacionDC2] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [STPS].[tblProgramasCapacitacionDC2] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_STPSTblProgramasCapacitacionDC2]
GO
ALTER TABLE [STPS].[tblProgramasCapacitacionDC2]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpresa_STPSTblProgramasCapacitacionDC2_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [STPS].[tblProgramasCapacitacionDC2] CHECK CONSTRAINT [FK_RHTblEmpresa_STPSTblProgramasCapacitacionDC2_IDEmpresa]
GO
