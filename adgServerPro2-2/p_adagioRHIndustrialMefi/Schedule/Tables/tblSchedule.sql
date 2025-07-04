USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[tblSchedule](
	[IDSchedule] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[StoreProcedure] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[interval] [int] NOT NULL,
	[active] [bit] NOT NULL,
	[IDTipoAccion] [int] NOT NULL,
 CONSTRAINT [PK_ScheduleTblPlanificador_IDSchedule] PRIMARY KEY CLUSTERED 
(
	[IDSchedule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Schedule].[tblSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTblCatTipoAcciones_ScheduleTblSchedule_IDTipoAccion] FOREIGN KEY([IDTipoAccion])
REFERENCES [Schedule].[tblCatTipoAcciones] ([IDTipoAccion])
GO
ALTER TABLE [Schedule].[tblSchedule] CHECK CONSTRAINT [FK_ScheduleTblCatTipoAcciones_ScheduleTblSchedule_IDTipoAccion]
GO
