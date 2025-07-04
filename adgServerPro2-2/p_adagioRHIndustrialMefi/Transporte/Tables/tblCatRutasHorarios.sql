USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatRutasHorarios](
	[IDRutaHorario] [int] IDENTITY(1,1) NOT NULL,
	[IDRuta] [int] NULL,
	[HoraSalida] [time](7) NULL,
	[HoraLlegada] [time](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_tblCatRutasHorarios_IDRutaHorario] PRIMARY KEY CLUSTERED 
(
	[IDRutaHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatRutasHorarios] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Transporte].[tblCatRutasHorarios]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatRutas_TransportetblCatRutaHorarios_IDRuta] FOREIGN KEY([IDRuta])
REFERENCES [Transporte].[tblCatRutas] ([IDRuta])
GO
ALTER TABLE [Transporte].[tblCatRutasHorarios] CHECK CONSTRAINT [FK_TransportetblCatRutas_TransportetblCatRutaHorarios_IDRuta]
GO
